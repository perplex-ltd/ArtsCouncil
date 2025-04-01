import React = require("react");
import { IInputs } from "./generated/ManifestTypes";
import { UploadedFile } from "./interfaces/InterfaceHelper";
import Button from 'react-bootstrap/Button';

export interface AppControlState {
    files: Array<UploadedFile>;
    acceptedFileTypes: string;
}


export class App extends React.Component<any, AppControlState> {
    constructor(props: any) {
        super(props);
        this.state = { files: props.files ?? [], acceptedFileTypes: props.acceptedFileTypes };
        this._outputType = props.outputType;
        this._context = this.props.context;
        this.DeleteFile = this.DeleteFile.bind(this);
    }
    private _context: ComponentFramework.Context<IInputs>;
    private _outputType: string;
    private _type: string;
    private _fileName: string;

    public onFileInputChange = (e: any) => {
        var _fileInput = document.getElementById("inpUploader") as HTMLInputElement;
        if (_fileInput?.files?.length === 0) {
            //this._notifyOutputChanged()
            return;
        }
        let file = _fileInput?.files![0];
        this._fileName = file.name;
        this._type = file.type;
        var fileReader = new FileReader();
        fileReader.onloadend = () => {
            //this._value = fileReader.result as string;

            var _files = this.state.files;
            //..._files,
            _files.push({
                name: this._fileName ?? "name",
                value: fileReader.result as string,
                type: this._type ?? "type",
                id: Math.random()
            });
            this.setState({ files: _files });
            this.props.updateOutput(_files);
        }

        if (this._outputType === 'Text') {
            fileReader.readAsText(file);
        }
        else {
            fileReader.readAsDataURL(file);
        }
    }
    DeleteFile(id: number) {
        this.setState({ files: this.state.files.filter((p: UploadedFile) => p.id != id) });
        this.props.updateOutput(this.state.files.filter((p: UploadedFile) => p.id != id));
    }

    render() {
        return (
            <div className="App">
                <input id="inpUploader" type="file"
                    style={{ display: "block", pointerEvents: "auto", opacity: 100, width: "100%", height: "30px" }}
                    onChange={(e: any) => this.onFileInputChange(e)} accept={this.state.acceptedFileTypes} />
                <div>
                    {this.state.files.length > 0 &&
                        <table style={{ width: "100%", overflow:"auto" , display:"block", height:"80px" }}>
                            <tr>
                                <th style={{width:"70%"}}><strong>Name</strong></th>
                                {/* <th style={{width:"20%"}}><strong>Type</strong></th> */}
                                <th style={{width:"30%"}}>&nbsp;</th>
                            </tr>
                            {this.state.files.map((file: UploadedFile) => {
                                //this.state.files.forEach((file,i)=>{
                                return (
                                    <tr key={file.id}>
                                        <td>{file.name}</td>
                                        {/* <td>{file.type}</td> */}
                                        <td>
                                        &nbsp;
                                        &nbsp;
                                            <Button variant="primary" style={{cursor:"pointer"}} onClick={(e: any) => this.DeleteFile(file.id)}>Remove</Button>
                                            {/* <input  aria-label="Delete" type="button" onClick={(e: any) => this.DeleteFile(file.id)}></input> */}
                                        </td>
                                    </tr>
                                )
                            })}
                            {/* {this.state.files.length==0  && 
                                <tr key={35}>
                                    <td>No file to display here</td>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>                            
                        } */}
                        </table>
                    }
                </div>
            </div>);
    }
}