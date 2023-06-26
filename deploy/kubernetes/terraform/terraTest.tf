# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Update with your desired region
}

# Create a security group to allow incoming traffic to the EC2 instance and RDS instance
resource "aws_security_group" "instance" {
  name_prefix = "instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99" # Update with your desired AMI
  instance_type = "t3.micro"
  security_groups = [aws_security_group.instance.id]
}

# Create the RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "example"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  iam_database_authentication_enabled = true
}

# Create the S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"
}


resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}


# Make the S3 bucket publicly accessible
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}
