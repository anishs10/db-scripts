configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to '/backup/%F';
configure maxsetsize to unlimited;
configure device type disk parallelism 4;
run
{
allocate channel c1 type disk format '/backup/%I-%Y%M%D-%U' maxpiecesize 3G;
allocate channel c2 type disk format '/backup/%I-%Y%M%D-%U' maxpiecesize 3G;
backup tablespace USERS;
release channel c1 ;
release channel c2 ;
}