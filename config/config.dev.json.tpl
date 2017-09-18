{
  "Parameters" : {
    "CidrBlock": "10.1.0.0/16",
    "Environment": "dev",
    "FoundationBucket": "awsrig.${PROJECT}.${NAME_SUFFIX}.foundation",
    "ProjectName": "${PROJECT}",
    "PublicDomain": "${DOMAIN}",
    "PublicFQDN": "${SUBDOMAIN}-dev.${DOMAIN}",
    "Region": "${REGION}",
    "SubnetPrivateCidrBlocks": "10.1.11.0/24,10.1.12.0/24,10.1.13.0/24",
    "SubnetPublicCidrBlocks": "10.1.1.0/24,10.1.2.0/24,10.1.3.0/24"
  }
}
