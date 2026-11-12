# Operating scenarios

How this stack behaves when things go wrong, and what I'd do. (Names refer to resources in `main.tf`.)

## 1. The CPU alarm fires (`<project>-<env>-cpu-high`)

You get an SNS email. No SSH key exists by design, so connect with Session Manager:

```bash
aws ssm start-session --target <instance-id>          # see: terraform output ssm_connect_command
top -b -n1 | head -15 ; vmstat 1 5                    # who is using CPU? is it steal or I/O wait?
sudo journalctl -u nginx --since "30 min ago" | tail
```

- Traffic spike or runaway process -> mitigate, then consider a bigger instance type or an Auto Scaling group.
- Check the CloudWatch graph: a flat 100% line is a stuck process; a sawtooth is load.
- The alarm uses 2 x 5-minute periods, so brief spikes don't page anyone; tune `cpu_alarm_threshold`.

## 2. Status-check alarm fires (`status-check-failed`)

- *System* check failure = underlying AWS host problem -> stop/start the instance to move it to new hardware.
- *Instance* check failure = OS-level problem (kernel panic, full disk, bad network config) -> look at the console output (`aws ec2 get-console-output`) and the system log.
- Add an EC2 auto-recovery action on this alarm if you want it automated.

## 3. "Terraform wants to destroy my instance"

```bash
terraform plan -out tfplan && terraform show tfplan | grep -B2 -A6 "must be replaced"
```
- `user_data` changes force replacement. Decide whether that's acceptable, or move configuration to SaltStack/SSM so the instance isn't rebuilt for config changes.
- Never `apply` a plan you haven't read, especially "forces replacement" lines.

## 4. Drift - someone changed something in the console

```bash
terraform plan     # drift shows up as unexpected changes
```
Re-apply to restore the declared state, or import/codify the change if it was intentional.

## 5. S3 bucket gets bigger and bigger

Versioning is on, so overwritten objects are kept. The lifecycle rule expires **noncurrent** versions after 30 days. Check `aws s3api list-object-versions` if costs climb and adjust the retention.
