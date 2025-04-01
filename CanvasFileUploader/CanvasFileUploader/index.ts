import React = require("react");
import {IInputs, IOutputs} from "./generated/ManifestTypes";
import { App } from "./App";
var ReactDOM = require('react-dom/client');
import { UploadedFile } from "./interfaces/InterfaceHelper";

export class CanvasFileUploader implements ComponentFramework.StandardControl<IInputs, IOutputs> {

    private _container: HTMLDivElement;
    private context: ComponentFramework.Context<IInputs>;
    private _value: Array<UploadedFile>;
    private _acceptedFileTypes: string;
	private _outputType:string;
    private _notifyOutputChanged: () => void;

    constructor()
    {
        this.updateOutput = this.updateOutput.bind(this);
    }

    public init(context: ComponentFramework.Context<IInputs>, notifyOutputChanged: () => void, state: ComponentFramework.Dictionary, container:HTMLDivElement): void
    {        
        this.context = context;
        this._notifyOutputChanged = notifyOutputChanged;
        this._container = container;
		this.updateOutput=this.updateOutput.bind(this);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void
    {
		this._acceptedFileTypes= this.context.parameters.acceptedFileTypes.raw ?? "";
		this._outputType= this.context.parameters.outputType.raw ?? "";
        const root = ReactDOM.createRoot(this._container);
        root.render(React.createElement(App, { context: context,files:this._value, acceptedFileTypes: this._acceptedFileTypes ,outputType:this._outputType, updateOutput: this.updateOutput }));
    }

    public updateOutput(files: Array<UploadedFile>) {
        this._value = files;
        this._notifyOutputChanged();
    }

    public getOutputs(): IOutputs
    {        return {	
			value:JSON.stringify( this._value) ?? "{}"
		};
    }

    public destroy(): void
    {
    }
}