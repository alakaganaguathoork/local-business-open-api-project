get ami for Ubuntu:
```bash
aws ec2 describe-images \
    --owners 099720109477   \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*" "Name=state,Values=available" \
    --region eu-north-1 \
    --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" \
    --output text
```