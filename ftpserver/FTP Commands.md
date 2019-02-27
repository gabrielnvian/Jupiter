| **Command** | **Description**                                                     | **Status** |
|-------------|---------------------------------------------------------------------|------------|
| CDUP        | Change to Parent Directory.                                         |            |
| CWD         | Change working directory.                                           |            |
| DELE        | Delete file.                                                        |            |
| LIST        | Information of the current working directory.                       |            |
| MKD         | Make directory.                                                     |            |
| QUIT / BYE  | Disconnect.                                                         |            |
| RETR        | Retrieve a copy of the file                                         |            |
| RMD         | Remove a directory.                                                 |            |
| SIZE        | Return the size of a file.                                          |            |
| STAT        | Returns the current status.                                         |            |
| STOR        | Accept the data and to store the data as a file at the server site. |            |
| TYPE        | Sets the transfer mode.                                             |            |
| ABOR        | Abort an active file transfer.                                      |            |
| PWD         | Print working directory. Returns the current directory of the host. |     OK     |
| PASS        | Authentication password.                                            |     OK     |
| USER        | Authentication username.                                            |     OK     |
| AUTH        | Request TLS/SSL.                                                    |     OK*    |
| MLST        | Lists the contents of a directory if a directory is named.          |            |
| FEAT        | Lists the features of the server.                                   |            |
| EPRT        | Returns the long address to which the server should connect.        |            |
| MFMT        | Edit last modification time of a file.                              |            |
| MDTM        | Returns last modify time of a file.                                 |            |