#!/usr/bin/php
<?php
// See http://php.net/manual/function.imap-open.php for more information about
// the mailbox string in the first parameter of imap_open.
// This example is ready to use with Office 365 Exchange Mails,
// just replace your username (=email address) and the password.
$mbox = imap_open("{localhost:1243}", "dany@conselio.com", "conselio");

// Total number of emails
$nrTotal = imap_num_msg($mbox);

// Number of unseen emails. There are other ways using imap_status to count
// unseen messages, but they don't work with Office 365 Exchange. This one does.
$unseen = imap_search($mbox, 'UNSEEN');
$nrUnseen = $unseen ? count($unseen) : 0;

// Display the result, format as you like.
echo $nrUnseen.'/'.$nrTotal;

// Not needed, because the connection is closed after the script end.
// For the sake of clean public available scripts, we are nice to
// the imap server and close the connection manually.
imap_close($mbox);
