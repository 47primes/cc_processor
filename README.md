## CCProcessor

Basic Credit Card Processing

### Requirements

Ruby >= 1.9.3

### Installation

```bash
cd /path/to/cc_processor/
gem install cc_processor-0.1.gem
```

### Usage

`cc_processor COMMAND [arguments]`

executes a single command

specific commands: 

`Add <Name> <Number> <Limit>`
creates a new credit card for a given name, card number, and limit

`Charge <Name> <Amount>`
increases the balance of the card associated with the provided name by the amount specified

`Credit <Name> <Amount>`
decreases the balance of the card associated with the provided name by the amount specified

`cc_processor path_to_batch_file`

executes multiple commands as listed in a batch file Each line in the file must contain a single command.

Example:
```
Add Tom 4111111111111111 $1000
Add Lisa 5454545454545454 $3000
Add Quincy 1234567890123456 $2000
Charge Tom $500
Charge Tom $800
Charge Lisa $7
Credit Lisa $100
Credit Quincy $200
```

`cat path_to_batch_file | cc_processor`

executes multiple commands from STDIN

Each line must contain a single command as described above.

### Running Specs

#### Install Bundler gem

`gem install bundler`

#### Install and Run RSpec

```bash
cd /path/to/cc_processor

bundle install

rspec .
```

### Notes

This software is written in Ruby, for that is the one in which the I am the most fluent. 

It is written as a gem because I've written several, and I like the way it forces me to organize my code in a consistent manner. In addition, it offers a straightforward way to install and evaluate execution.

The decision to use a persistent data store, SQLite, was motivated by a desire to persist credit card data between executions. This resulted in much boilerplate code for little benefit, as a subsequent review of the instructions revealed no specific requirement to persist code for subsequent executions. So the data is reloaded for each run to ensure idempotence. Rather than strip this code out, the author decided to go along with it in the intent that it could be useful for additional functionality in the future. A simpler design could have been to employ ActiveModel rather than ActiveRecord in order to get the benefit of attributes, validations, and callbacks without the data persistence.

The software is organized into 3 classes:

The `CLI` class is responsible for parsing command-line arguments, executing them, and building and displaying output.

The single data model, `CreditCard` defines, validates, and persists data with just a smidgen of presentation logic.

The `Database` class is responsible for connecting to the database, creating the table based on the defined schema, and dropping the connection when done.
