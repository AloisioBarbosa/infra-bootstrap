data "aws_iam_policy_document" "github_actions_infra_cluster_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_organization}@${var.github_owner_id}/infra-cluster@${var.infra_cluster_repository_id}:environment:production",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_infra_cluster" {
  name               = "GitHubActionsOIDCInfraClusterRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_infra_cluster_trust.json

  depends_on = [
    aws_iam_role_policy.github_actions_infra_bootstrap,
  ]
}

data "aws_iam_policy_document" "github_actions_infra_cluster" {
  statement {
    sid       = "ListTerraformStateBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_state.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["cluster/dev/*"]
    }
  }

  statement {
    sid    = "ManageTerraformStateObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/cluster/dev/*"]
  }

  statement {
    sid       = "ReadNetworkContract"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/infra-network/vpc/*"]
  }

  statement {
    sid    = "ManageEksResources"
    effect = "Allow"
    actions = [
      "eks:AssociateAccessPolicy",
      "eks:CreateAccessEntry",
      "eks:CreateAddon",
      "eks:CreateCluster",
      "eks:CreateFargateProfile",
      "eks:CreateNodegroup",
      "eks:DeleteAccessEntry",
      "eks:DeleteAddon",
      "eks:DeleteCluster",
      "eks:DeleteFargateProfile",
      "eks:DeleteNodegroup",
      "eks:DescribeAccessEntry",
      "eks:DescribeAddon",
      "eks:DescribeAddonConfiguration",
      "eks:DescribeAddonVersions",
      "eks:DescribeCluster",
      "eks:DescribeFargateProfile",
      "eks:DescribeNodegroup",
      "eks:DisassociateAccessPolicy",
      "eks:ListAccessEntries",
      "eks:ListAccessPolicies",
      "eks:ListAddons",
      "eks:ListAssociatedAccessPolicies",
      "eks:ListFargateProfiles",
      "eks:ListNodegroups",
      "eks:ListTagsForResource",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:UpdateAccessEntry",
      "eks:UpdateAddon",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageClusterEc2Resources"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageClusterRolesAndInstanceProfile"
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteInstanceProfile",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetInstanceProfile",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:TagRole",
      "iam:UntagInstanceProfile",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.infra_cluster_name}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.infra_cluster_name}-cluster-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.infra_cluster_name}-fargate-pod-execution",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.infra_cluster_name}-nodes-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterControllerRole-${var.infra_cluster_name}",
    ]
  }

  statement {
    sid    = "ManageEksOidcProvider"
    effect = "Allow"
    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviderTags",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/*"]
  }

  statement {
    sid    = "ManageClusterKmsKey"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:DisableKey",
      "kms:EnableKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:UpdateAlias",
      "kms:UpdateKeyDescription",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageKarpenterInterruptionQueue"
    effect = "Allow"
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
    ]
    resources = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.infra_cluster_name}-karpenter-interruptions"]
  }

  statement {
    sid    = "ManageKarpenterEventRules"
    effect = "Allow"
    actions = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:ListTagsForResource",
      "events:ListTargetsByRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:TagResource",
      "events:UntagResource",
    ]
    resources = ["arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/${var.infra_cluster_name}-karpenter-*"]
  }
}

resource "aws_iam_role_policy" "github_actions_infra_cluster" {
  name   = "TerraformInfraClusterPolicy"
  role   = aws_iam_role.github_actions_infra_cluster.id
  policy = data.aws_iam_policy_document.github_actions_infra_cluster.json
}
