import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

let elm = Main.embed(document.getElementById('root'));

elm.ports.outgoingCommand.subscribe(function(command) {
    console.log({ outgoingCommand: command })
})

elm.ports.serverStateUpdate.send({
    failedJobs: [
        { id: "test", worker: "FooWorker" },
        { id: "test2", worker: "FooWorker" }
    ]
})

registerServiceWorker();
