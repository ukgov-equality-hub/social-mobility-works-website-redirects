
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.service_name}__iam_role_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_lambda_function" "redirect_lambda_function" {
  // CloudFront distributions have to be created in the us-east-1 region (for some reason!)
  provider = aws.us-east-1

  runtime = "nodejs18.x"

  function_name = "${var.service_name}__redirect_lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn

  filename      = "${var.service_name}__redirect_lambda_code.zip"
  handler       = "redirect_lambda_code.handler"
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256

  publish = true
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source {
    filename = "redirect_lambda_code.js"
    content = <<EOT
'use strict';

exports.handler = (event, context, callback) => {
    function create_redirect(redirect_to_url) {
        return {
            status: '302',
            statusDescription: 'Found',
            headers: {
                location: [{
                    key: 'Location',
                    value: redirect_to_url,
                }],
            },
        };
    }

    function urls_match(request_url, redirect_from_url, case_sensitive) {
        if (redirects[i].case_sensitive) {
            return (request_url === redirect_from_url);
        }
        else {
            return (request_url.toLowerCase() === redirect_from_url.toLowerCase());
        }
    }

    const redirects = ${local.redirects_json_text};

    const request = event.Records[0].cf.request;

    for (var i = 0; i < redirects.length; i++) {
        if (urls_match(request.uri, redirects[i].from, redirects[i].case_sensitive)) {
            const response = create_redirect(redirects[i].to);
            callback(null, response);
            return;
        }
    }

    const response = create_redirect("${local.redirect_everything_else_to}");
    callback(null, response);
    return;
};
EOT
  }
  output_path = "${var.service_name}__redirect_lambda_code.zip"
}
