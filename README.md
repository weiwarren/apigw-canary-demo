# API Gateway Canary Deployment Demo


## Installation
### k6
install k6 using the test/setup.sh on Ubunutu

### terraform
ensure you have terraform binary installed

### AWS cli
make sure you have aws cli configured

### Permission
`chmod +x deploy.sh`
`chmod +x test/test.sh`

## Usage
1. Deploy terraform
`. ./deploy.sh`
```this will export the output uri into an env after the terraform deploy

2. Run tests
./test/test.sh

