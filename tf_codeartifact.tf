resource "aws_codeartifact_domain" "cad_ac_tf_codepipeline" {
  domain = "cad-ac-tf-codepipeline"
}

resource "aws_codeartifact_repository" "car_ac_tf_codepipeline" {
  repository = "car-ac-tf-codepipeline"
  domain     = aws_codeartifact_domain.cad_ac_tf_codepipeline.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }
}