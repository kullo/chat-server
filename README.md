# KulloChatServer

## Running local tests on PostgreSQL

* `brew install postgresql`
* `brew services start postgresql`
* `createdb chatserver-test`
* Edit scheme -> Test -> Arguments
* Add environment variable: `DATABASE_URL` = `postgres://daniel:@localhost:5432/chatserver-test` (change username to your system username)
