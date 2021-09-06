provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "jiraiya106-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }
    
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#############################################################################
# Amazon DynamoDB - это распределенное хранилище ключей и значений
# Он поддерживает строго согласованные операции чтения и условной записи,
#  которые являются всеми компонентами, необходимыми для системы распределенной блокировки
#############################################################################

# В DynamoDB создадим таблицу "terraform_locks" с первичным ключом "LockID" для использования блокировки
# 
resource "aws_dynamodb_table" "terraform_locks" {
    name = "jiraiya106-terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    
    attribute {
        name = "LockID"
        type = "S"
    }
}

#############################################################################
# ВЫХОДНЫЕ ПЕРЕМЕННЫЕ
#############################################################################

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "ARN(Amazon Resource Name) S3 Bucket"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "Таблица DynamoDB"
}
