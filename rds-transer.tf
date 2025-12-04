resource "aws_db_cluster_snapshot" "example" {
  db_cluster_identifier          = "new-teadifyz-db"
  db_cluster_snapshot_identifier = "resourcetestsnapshot1234"
}


# data "aws_db_cluster_snapshot" "development_final_snapshot" {
#   db_cluster_identifier = "resourcetestsnapshot1234"
#   most_recent           = true
# }


# 2️⃣ Use the snapshot to create a new DB cluster
resource "aws_db_cluster" "new_restore_cluster" {
  cluster_identifier              = "wow-db"
  snapshot_identifier             = aws_db_cluster_snapshot.example.id
  engine                          = "postgresql"             # change based on your DB
  engine_version                  = "17.6"  # match your version
  database_name                   = "restored_db"              # optional
  master_username                 = jsondecode(aws_secretsmanager_secret_version.example.secret_string).username                    # must provide when restoring
  master_password                 = jsondecode(aws_secretsmanager_secret_version.example.secret_string).password    # sensitive, move to SSM/TF vars
  storage_encrypted               = true
  skip_final_snapshot             = true

  vpc_security_group_ids          = ["sg-0123456789abcdef"]    # Update
  db_subnet_group_name            = "my-db-subnet-group"        # Update
}

