## Auth.adduser
### Inputs
| Parameter       | Description                              |
|-----------------|------------------------------------------|
| usr             | Username for the new user                |
| pwd             | Password for the new user                |
| reqpow          | Power level of the caller of this action |
| (pow) => rewpow | Power level for the new user             |

### Outputs
| Code | Description                                          |
|------|------------------------------------------------------|
| 0    | User created successfully                            |
| 1    | User already exists                                  |
| 2    | Cannot create an user with higher PW than the caller |


## Auth.changepwd
### Inputs
| Parameter     | Description                                                                                   |
|---------------|-----------------------------------------------------------------------------------------------|
| usr           | Username of the user                                                                          |
| pwd           | New password for the user                                                                     |
| (old) => nil  | Use this if you change the password yourself knowing the old one                              |
| (reqpow) => 0 | If the old password is not known you can change it using another account with higher PW level |

### Outputs
| Code | Description                                                                  |
|------|------------------------------------------------------------------------------|
| 0    | Password changed successfully                                                |
| 1    | Password does not match and user PW level is higher than the caller PW level |


## Auth.deluser
### Inputs
| Parameter     | Description                                                                                          |
|---------------|------------------------------------------------------------------------------------------------------|
| usr           | Username of the user                                                                                 |
| (pwd) => nil  | User password. Use this if you delete an account you know the password of                            |
| (reqpow) => 0 | Caller PW level.If you don't know the password for the user use another account with higher PW level |

### Outputs
| Code | Description                                                                  |
|------|------------------------------------------------------------------------------|
| 0    | Password changed successfully                                                |
| 1    | Password does not match and user PW level is higher than the caller PW level |