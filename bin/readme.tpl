## "do" is the simplest way to manage callbacks.

If you don't want to use all the async/chain libraries but just want a reliable way to know when the function is done - this is for you.

The most important about "do" is its flexibility. It doesn't force you to structure your code at any specific way.

## Installation
    npm i do

## Usage

 You need to specify "error" + "success" or "complete" callback, otherwise "Do" will throw an error.

    var Do = require('do');
    var todo = Do(1);
    // use success and error callbacks
    todo.error();
    todo.success(success);
    // or use complete callback
    todo.complete(function() {
        console.log(this.errors);
    });
    todo.done();

## Caveats

While using `Do#inc`, `Do#dec` or `Do#amount` for setting conditionally amount of todos is very convinent, it has a dangerous downside. If the function which accepts the `Do#done` callback invokes it synchronously, `Do` will fire success function before it comes to the execution of all further conditional amount increments. In this case all todos are done before all of them could be defined.

Example:

    var todo = Do(); // 0 is default
    todo.complete(function() {});
    if (a == 1) {
        todo.inc();
        doSomething(todo.done);
    }
    if (a == 2) {
        todo.inc();
        doSomething(todo.done);
    }
    function doSometing(callback) {
        // sync callback invocation
        callback();
    }

If you are not sure whether your functions are sync or async, you should start with todo amount value == +1 than know needed and mark that one as "done" at the end of all conditional incrementations.

Example:

    var todo = Do(1);
    todo.complete(function() {});
    if (a == 1) {
        todo.inc();
        doSomething(todo.done);
    }
    if (a == 2) {
        todo.inc();
        doSomething(todo.done);
    }
    function doSometing(callback) {
        // sync callback invocation
        callback();
    }
    // Mark the additional todo as done.
    todo.done();


The best way is to define the amount of all todos at the beginning, but unfortunately this is not always possible.

## Api

{api}

## Examples

### Mix parallel and serial executions

    var Do = require('do'),
        todo = new Do(2);

    todo.error(errorHandler);
    todo.success(successHandler);

    function parallelTask1(callback) {
        function serialTask1() {
            var todo = new Do(2);
            todo.error(callback);
            todo.success(serialTask2);
            parallelTask1(todo.done);
            parallelTask2(todo.done);
        }

        function serialTask2() {
            var todo = new Do(2);
            todo.error(callback);
            todo.success(callback);
            parallelTask1(todo.done);
            parallelTask2(todo.done);
        }

        serialTask1();
    }

    function parallelTask2(callback) {
        function serialTask1() {
            var todo = new Do(2);
            todo.error(callback);
            todo.success(serialTask2);
            parallelTask1(todo.done);
            parallelTask2(todo.done);
        }

        function serialTask2() {
            var todo = new Do(2);
            todo.error(callback);
            todo.success(callback);
            parallelTask1(todo.done);
            parallelTask2(todo.done);
        }

        serialTask1();
    }

    parallelTask1(todo.done);
    parallelTask2(todo.done);

### Express application

    var Do = require('do');

    app.post('/', function(req, res, next) {
        var todo = new Do(3);

        // If an error happens, next callback will be called and the error passed along.
        todo.error(next);

        // If everything is done and no errors happened, success callback is called.
        todo.success(function() {
            res.send({status: 'ok'});
        });

        db.fetch(userId, function(err, user) {
            if (err) return todo.done(err);

            update(user, todo.done);
            notify(user, todo.done);
            addSomeBackgroundTask(user, todo.done);

            if (userId == '123456') {
                todo.inc();
                specialTaskForTheUser(user, todo.done);
            }

            if (user.type == 'freak') {
                todo.inc(3);
                task1(user, todo.done);
                task2(user, todo.done);
                task3(user, todo.done);
            }
        });
    });

## Run tests

    npm test

## Licence

MIT
