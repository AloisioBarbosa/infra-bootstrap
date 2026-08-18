data "aws_iam_policy_document" "github_actions_infra_bootstrap_trust" {
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
        "repo:${var.github_organization}@${var.github_owner_id}/infra-bootstrap@${var.infra_bootstrap_repository_id}:environment:production",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_infra_bootstrap" {
  name               = "GitHubActionsOIDCInfraBootstrapRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_infra_bootstrap_trust.json
}

data "aws_iam_policy_document" "github_actions_infra_bootstrap" {
  statement {
    sid    = "ManageBootstrapRoles"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsOIDCInfraPlataformRole",
      aws_iam_role.api_gateway_logging.arn,
      aws_iam_role.github_actions_infra_bootstrap.arn,
      aws_iam_role.github_actions_infra_network.arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsOIDCInfraClusterRole",
    ]
  }

  statement {
    sid     = "CreateEksFargateServiceLinkedRole"
    effect  = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-fargate.amazonaws.com/AWSServiceRoleForAmazonEKSForFargate",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["eks-fargate.amazonaws.com"]
    }
  }

  statement {
    sid    = "ManageEksFargateServiceLinkedRole"
    effect = "Allow"
    actions = [
      "iam:DeleteServiceLinkedRole",
      "iam:GetRole",
      "iam:ListRoleTags",
      "iam:TagRole",
      "iam:UntagRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-fargate.amazonaws.com/AWSServiceRoleForAmazonEKSForFargate",
    ]
  }

  statement {
    sid       = "ReadServiceLinkedRoleDeletionStatus"
    effect    = "Allow"
    actions   = ["iam:GetServiceLinkedRoleDeletionStatus"]
    resources = ["*"]
  }

  statement {
    sid    = "ManageGitHubOIDCProvider"
    effect = "Allow"
    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]
    resources = [aws_iam_openid_connect_provider.github_actions.arn]
  }

  statement {
    sid    = "PassApiGatewayLoggingRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [aws_iam_role.api_gateway_logging.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["apigateway.amazonaws.com"]
    }
  }

  statement {
    sid    = "ManageTerraformStateBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLogging",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetAccelerateConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:GetBucketObjectLockConfiguration",
      "s3:PutEncryptionConfiguration",
    ]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    sid    = "ManageBootstrapState"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/bootstrap/dev/*"]
  }

  statement {
    sid    = "ManageApiGatewayAccount"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "apigateway:PATCH",
    ]
    resources = ["arn:aws:apigateway:${var.region}::/account"]
  }
}

resource "aws_iam_role_policy" "github_actions_infra_bootstrap" {
  name   = "TerraformInfraBootstrapPolicy"
  role   = aws_iam_role.github_actions_infra_bootstrap.id
  policy = data.aws_iam_policy_document.github_actions_infra_bootstrap.json
}
