provider "aws" {
  region = "us-east-1"
}

# Snapshot created without cluster_identifier
resource "aws_redshift_snapshot" "snapshot_orphaned" {
  snapshot_identifier = "redshift-snapshot-orphaned"
}
