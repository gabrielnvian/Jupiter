## Command **INIT**
### Parameters
| Parameter                        | Description                                                               |
|----------------------------------|---------------------------------------------------------------------------|
| :Name                            | The original name of the file                                             |
| :Ext                             | The original extension of the file                                        |
| :Date                            | Current date                                                              |
| :Keywords                        | Array containing some keywords for query                                  |
| (:Owner) => user logged in / nil | Owner of the file, can access the file no matter which is the minPW level |
| (:minPW) => user PW level / 0    | minPW needed to access the file                                           |


## Command **SUBMIT**
| Parameter | Description                                 |
|-----------|---------------------------------------------|
| :Ticket   | The ticket retrieved before on INIT command |