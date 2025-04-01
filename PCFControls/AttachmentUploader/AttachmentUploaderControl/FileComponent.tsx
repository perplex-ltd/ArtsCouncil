import * as React from "react";
import { FileIcon, defaultStyles } from 'react-file-icon';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash } from "@fortawesome/free-solid-svg-icons";
import { IconProp } from "@fortawesome/fontawesome-svg-core";

import "./styles.css"

interface File {
  id: string;
  name: string;
  size: number;
}

interface FileComponentProps {
  file: File;
  onDelete: (id: string) => void;
}

const FileComponent: React.FC<FileComponentProps> = (props: FileComponentProps) => {

  const extension: string = props.file.name.split('.').pop() || '';

  function formatBytes(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }  

  return (
    <div className={"file"} >
      {/*<div style={{ display: 'flex', alignItems: 'center', margin: '10px 0' }} className="attachment-item">*/}
        <div className={"file-icon"}> 
           <FileIcon size={12} extension={extension} {...defaultStyles[extension]}  className={'fileicon'}/>
        </div>
        <div className={"file-info"}>
          <span className={"file-name"}>{props.file.name}</span>
          <span className={"file-size"}>{formatBytes(props.file.size)}</span>
        </div>
        <div className={"remove-icon"}>
          <button onClick={() => props.onDelete(props.file.id)} className="remove-button">
            <FontAwesomeIcon icon={faTrash as IconProp} height={10} />
          </button>
        </div>
    </div>
  );
};

export default FileComponent;
