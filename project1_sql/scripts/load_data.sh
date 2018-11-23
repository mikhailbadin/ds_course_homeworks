#!/bin/sh
# How to run ./load_data.sh FOLDER_WITH_SOURCE_DATASET POSGRES_HOST POSGRES_PORT
FOLDER_WITH_SOURCE_DATASET=$1
POSGRES_HOST=$2
POSGRES_PORT=$3

ALIASES_FILEPATH="$FOLDER_WITH_SOURCE_DATASET./Aliases.csv"
EMAIL_RECEIVERS_FILEPATH="$FOLDER_WITH_SOURCE_DATASET./EmailReceivers.csv"
EMAILS_FILEPATH="$FOLDER_WITH_SOURCE_DATASET./Emails.csv"
PERSONS_FILEPATH="$FOLDER_WITH_SOURCE_DATASET./Persons.csv"

echo "Drop tables"
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "drop table if exists aliases"

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "drop table if exists emailreceivers"

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "drop table if exists emails"

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "drop table if exists persons"

echo "Load \"$ALIASES_FILEPATH\""
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c '
    create table if not exists aliases(
        Id bigint,
        Alias varchar(256),
        PersonId bigint);
    '

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "\\copy aliases FROM '$ALIASES_FILEPATH' DELIMITER ',' CSV HEADER"

echo "Load \"$EMAIL_RECEIVERS_FILEPATH\""
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c '
    create table if not exists emailreceivers(
        Id bigint,
        EmailId bigint,
        PersonId bigint);
    '

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "\\copy emailreceivers FROM '$EMAIL_RECEIVERS_FILEPATH' DELIMITER ',' CSV HEADER"

echo "Load \"$EMAILS_FILEPATH\""
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c '
    create table if not exists emails(
        Id bigint,
        DocNumber varchar(256),
        MetadataSubject varchar(256),
        MetadataTo varchar(256),
        MetadataFrom varchar(256),
        SenderPersonId bigint,
        MetadataDateSent timestamp,
        MetadataDateReleased timestamp,
        MetadataPdfLink varchar(256),
        MetadataCaseNumber varchar(256),
        MetadataDocumentClass varchar(256),
        ExtractedSubject varchar(256),
        ExtractedTo varchar(256),
        ExtractedFrom varchar(256),
        ExtractedCc varchar(256),
        ExtractedDateSent varchar(256),
        ExtractedCaseNumber varchar(256),
        ExtractedDocNumber varchar(256),
        ExtractedDateReleased varchar(256),
        ExtractedReleaseInPartOrFull varchar(256),
        ExtractedBodyText text,
        RawText text);
    '

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "\\copy emails FROM '$EMAILS_FILEPATH' DELIMITER ',' CSV HEADER"

echo "Load \"$PERSONS_FILEPATH\""
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c '
    create table if not exists persons(
        Id bigint,
        Name varchar(256));
    '

psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -c \
    "\\copy persons FROM '$PERSONS_FILEPATH' DELIMITER ',' CSV HEADER"


