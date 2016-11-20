output "EFS DNS NAME" {
  value = "${aws_efs_mount_target.efs_mount.dns_name}"
}