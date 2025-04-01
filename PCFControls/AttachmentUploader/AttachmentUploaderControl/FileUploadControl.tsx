/* eslint-disable  @typescript-eslint/no-explicit-any */
import * as React from "react";
import { IInputs } from "./generated/ManifestTypes";
import { useDropzone } from 'react-dropzone';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { faSpinner, faTrash } from '@fortawesome/free-solid-svg-icons';

import { v4 as uuidv4 } from 'uuid';
import FileComponent from "./FileComponent";

import { AttachmentTitle, Attachment } from './Types';
import "./styles.css"


export interface UploadProps {
    itemid: string;
    entityName: string;
    entitySetName: string;
    context: ComponentFramework.Context<IInputs> | undefined;
    webAPI: ComponentFramework.WebApi;
    files: Attachment[];
    isInTestHarness: boolean;
}

export interface FileInfo {
    name: string;
    type: string;
    body: string;
    size: number;
}


interface FileUploadControlProps {
    onFilesUploaded: (files: File[]) => void;
    uploadedFiles: File[];
}

export const FileUploadControl: React.FC<UploadProps> = (uploadProps: UploadProps) => {

    const UploadIcon = "data:image/png;base64,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";

    const [totalFileCount, setTotalFileCount] = React.useState(0);
    const [currentUploadCount, setCurrentUploadCount] = React.useState(0);
    const [deletingFile, setDeletingFile] = React.useState(false);

    const [files, setFiles] = React.useState(uploadProps.files);

    const onDrop = React.useCallback((acceptedFiles: any) => {

        if (acceptedFiles && acceptedFiles.length) {
            setTotalFileCount(acceptedFiles.length);
        }


        const toBase64 = async (file: any) => new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = () => resolve(reader.result);
            reader.onabort = () => reject();
            reader.onerror = error => reject(error);
        });

        // called by uploadFiletoCRM, uploads ONE file
        const uploadFileToRecord = async (id: string, entity: string, entitySetName: string,
            fileInfo: FileInfo, context: ComponentFramework.Context<IInputs>): Promise<ComponentFramework.LookupValue> => {

            const attachmentRecord: ComponentFramework.WebApi.Entity = {};
            attachmentRecord[`objectid_${entity}@odata.bind`] = `/${entitySetName}(${id})`;
            attachmentRecord["documentbody"] = fileInfo.body;

            attachmentRecord["subject"] = AttachmentTitle;


            if (fileInfo.type && fileInfo.type !== "") {
                attachmentRecord["mimetype"] = fileInfo.type;
            }

            attachmentRecord["filename"] = fileInfo.name;
            attachmentRecord["objecttypecode"] = entity;
            const attachmentEntity = "annotation";

            if (!uploadProps.isInTestHarness) {
                return await context.webAPI.createRecord(attachmentEntity, attachmentRecord);
            } else {
                await new Promise((resolve) => setTimeout(resolve, 2000));
                return {
                    id: uuidv4(),
                    entityType: "annotation"
                };
            }
        }


        // initialises all uploads
        const uploadFilesToCRM = async () => {


            try {
                const newFiles = [...files];
                for (let i = 0; i < acceptedFiles.length; i++) {
                    setCurrentUploadCount(i+1);
                    const file = acceptedFiles[i] as any;
                    const base64Data = await toBase64(acceptedFiles[i]);
                    const base64DataStr = base64Data as string;
                    const base64IndexOfBase64 = base64DataStr.indexOf(';base64,') + ';base64,'.length;
                    const base64 = base64DataStr.substring(base64IndexOfBase64);
                    const fileInfo: FileInfo = {
                        name: file.name,
                        type: file.type,
                        body: base64,
                        size: file.size
                    };
                    let entityId = uploadProps.itemid;
                    let entityName = uploadProps.entityName;

                    if (entityId == null || entityId === "") {//this happens when the record is created and the user tries to upload
                        let currentPageContext = uploadProps.context as any;
                        currentPageContext = currentPageContext ? currentPageContext["page"] : undefined;
                        entityId = currentPageContext.entityId;
                        entityName = currentPageContext.entityTypeName;
                    }

                    const newRecord = await uploadFileToRecord(entityId, entityName, uploadProps.entitySetName, fileInfo, uploadProps.context!);
                    newFiles.push({
                        id: newRecord.id,
                        name: fileInfo.name,
                        size: fileInfo.size
                    });
                }
                setFiles(newFiles);
            }
            catch (e: any) {
                const errorMessagePrefix = (acceptedFiles.length === 1) ?
                    "Error while uploading attachment" : "Error while uploading attachments";
                const errOptions = { message: `${errorMessagePrefix} ${e.message}` };
                uploadProps.context?.navigation.openErrorDialog(errOptions)
            }

            setTotalFileCount(0);
            const xrmObj: any = (window as any)["Xrm"];
        }


        uploadFilesToCRM();

    }, [totalFileCount, currentUploadCount])

    const { getRootProps, getInputProps, isDragActive, open } = useDropzone({ noClick: true, onDrop: onDrop });

    const deleteFile: React.MouseEventHandler<HTMLButtonElement> = async (event: React.MouseEvent<HTMLButtonElement>) => {
        //    const deleteFile = React.useCallback(async (id: any) => {
        try {
            setDeletingFile(true);
            const button = event.currentTarget as HTMLButtonElement;
            const id = button.getAttribute('data-id');
            if (id) {
                //const id = "";
                if (!uploadProps.isInTestHarness) await uploadProps.webAPI.deleteRecord("annotation", id);
                else await new Promise(resolve => setTimeout(resolve, 2000));
                const newFiles: Attachment[] = [];
                files.forEach(a => {
                    if (a.id === id) {
                        // actually remove the file

                    } else {
                        newFiles.push(a)
                    };
                });
                setFiles(newFiles);
            }
            setDeletingFile(false);
        } catch (e: any) {
            const errOptions = { message: `Error while removing attachment: ${e.message}` };
            uploadProps.context?.navigation.openErrorDialog(errOptions)
        }
    };

    const deleteFileHandler = async (id: string) => {
        try {
            setDeletingFile(true);
            if (id) {
                //const id = "";
                if (!uploadProps.isInTestHarness) await uploadProps.webAPI.deleteRecord("annotation", id);
                else await new Promise(resolve => setTimeout(resolve, 2000));
                const newFiles: Attachment[] = [];
                files.forEach(a => {
                    if (a.id === id) {
                        // actually remove the file

                    } else {
                        newFiles.push(a)
                    };
                });
                setFiles(newFiles);
            }
            setDeletingFile(false);
        } catch (e: any) {
            const errOptions = { message: `Error while removing attachment: ${e.message}` };
            uploadProps.context?.navigation.openErrorDialog(errOptions)
        }
    };


    let fileStats = null;
    if (totalFileCount > 0 || deletingFile) {
        fileStats = (
            <div className={ "overlay"}>
                <div>
                    <FontAwesomeIcon icon={faSpinner as IconProp} inverse size="2x" spin />
                </div>
                {(totalFileCount > 0) &&
                    (<div className={"uploadStatusText"}>
                        Uploading attachment ({currentUploadCount}/{totalFileCount})
                    </div>)
                }
                {(deletingFile) &&
                    (<div className={"uploadStatusText"}>
                        Removing attachment...
                    </div>)
                }
            </div>
        );
    }


    return (
        <div className={"ac-container"}  {...getRootProps()}style={{ backgroundColor: isDragActive ? '#F8F8F8' : 'white' }} >
            <div className={"upload"} onClick={open}>
                <input {...getInputProps()} />
                <div>
                    <img className={"uploadImgDD"} src={UploadIcon} alt="Upload" />
                </div>
                <div>
                    {
                        isDragActive ?
                            <p>Drop files here...</p> :
                            <p>Drop files here or click to upload.</p>
                    }
                </div>
            </div>

            <div className={"attachment-list"}>
                {files.map((file: Attachment) =>(<FileComponent file={file} onDelete={deleteFileHandler} />))}
            </div>
            {fileStats}
            {(uploadProps.itemid == null || uploadProps.itemid === "")&& !uploadProps.isInTestHarness && (
            <div className={"overlay"}>
                <i>Error: id is null or empty!</i>
            </div>
            )}
        </div>
        
    );

}

