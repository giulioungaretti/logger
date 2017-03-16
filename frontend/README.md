# plogger

Log python messages with elm.

Read json formatted log messages from a websocket.


This project is bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

## TODO

- [] Implement local storage on save
- [] Pass port as flag ?
- [] Implement save as csv

## Installing Elm packages

```sh
elm-app package install <package-name>
```

## Installing JavaScript packages

To use JavaScript packages from npm, you'll need to add a `package.json`, install the dependencies, and you're ready to go.

```sh
npm init -y # Add package.json
npm install --save-dev pouchdb-browser # Install library from npm
```

```js
// Use in your JS code
var PouchDB = require('pouchdb-browser');
var db = new PouchDB('mydb');
```

## Folder structure
```
my-app/
  .gitignore
  README.md
  elm-package.json
  src/
    favicon.ico
    index.html
    index.js
    main.css
    Main.elm
  tests/
    elm-package.json
    Main.elm
    Tests.elm
```

## Available scripts for development
In the project directory you can run:
### `elm-app build`
Builds the app for production to the `dist` folder.  

The build is minified, and the filenames include the hashes.  
Your app is ready to be deployed!

### `elm-app start`
Runs the app in the development mode.  
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.  
You will also see any lint errors in the console.

### `elm-app test`
Run tests with [node-test-runner](https://github.com/rtfeldman/node-test-runner/tree/master)

You can make test runner watch project files by running:
```sh
elm-app test --watch
```
