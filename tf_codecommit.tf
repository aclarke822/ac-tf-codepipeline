resource "aws_codecommit_repository" "cc_react_frontend" {
  repository_name = "cc-react-frontend"
  description     = "react-frontend CodeCommit Repository"

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}