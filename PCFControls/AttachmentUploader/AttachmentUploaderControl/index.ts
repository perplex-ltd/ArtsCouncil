import * as React from 'react';
//import * as ReactDOM from 'react-dom';
import { createRoot, Root } from 'react-dom/client';
import { IInputs, IOutputs } from "./generated/ManifestTypes";
import { FileUploadControl, UploadProps } from "./FileUploadControl";

import { AttachmentTitle, Attachment } from './Types';

export class AttachmentUploaderControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {

	private _root: Root;
    private attachmentLoader: Promise<Attachment[]>;
    private isInTestHarness = false;

    /**
     * Empty constructor.
     */
    constructor() {
        // Empty
    }

    /**
     * Used to initialize the control instance. Controls can kick off remote server calls and other initialization actions here.
     * Data-set values are not initialized here, use updateView.
     * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to property names defined in the manifest, as well as utility functions.
     * @param notifyOutputChanged A callback method to alert the framework that the control has new outputs ready to be retrieved asynchronously.
     * @param state A piece of data that persists in one session for a single user. Can be set at any point in a controls life cycle by calling 'setControlState' in the Mode interface.
     * @param container If a control is marked control-type='standard', it will receive an empty div element within which it can render its content.
     */
    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        this.isInTestHarness = ((context as any)?.diagnostics?._controlId == "TestControl");
            
        this._root = createRoot(container);
        this.attachmentLoader = this.getResolutionFiles(context, context.parameters.itemId.raw!);

     }


    private async getResolutionFiles(
        context: ComponentFramework.Context<IInputs>,
        itemId: string
      ): Promise<Attachment[]> {
        const entityName = "annotation";
        const query = 
          `?$select=filename,filesize
           &$filter=(
             isdocument eq true and
             _objectid_value eq ${itemId} and
             subject eq '${AttachmentTitle}'
           )`;
        if (!itemId) return [];
        try {
            if (this.isInTestHarness)  {
                return [{
                    id: "feedface-baad-f00d-c0de-0ddba11af00d",
                    name: "Lorem Ipsum.pdf",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff1c",
                    name: "Dolor sit amet blob flap.xlsx",
                    size: 47470
                }/*
                ,
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff11",
                    name: "Dolor sit amet blob flap.docx",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff12",
                    name: "Dolor sit amet blob flap.pptx",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff13",
                    name: "Dolor sit amet blob flap.exe",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff14",
                    name: "Dolor sit amet blob flap.pdf",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff15",
                    name: "Dolor sit amet blob flap.png",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff16",
                    name: "Dolor sit amet blob flap.jpeg",
                    size: 47470
                },
                {
                    id: "0ff1c1al-f00d-b4ad-f00d-bad-f00d0ff17",
                    name: "Dolor sit amet blob flap.donkey",
                    size: 47470
                }*/];
            }
            const response = await context.webAPI.retrieveMultipleRecords(entityName, query);
            return response.entities.map((entity) => ({
                id: entity.annotationid,
                name: entity.filename,
                size: entity.filesize
            })) as Attachment[];
        } catch (error) {
          console.error("Error retrieving resolution files:", error);
          throw error;
        }
      }

    /**
     * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
     * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
     */
    public updateView(context: ComponentFramework.Context<IInputs>): void {

        const webapi = context.webAPI;
        const existingAttachments = this.attachmentLoader.then(
            (attachments: Attachment[]) => this.render(context, attachments))


    }
    
    private render(context: ComponentFramework.Context<IInputs>, attachments: Attachment[]): void {
        const props: UploadProps = {
            itemid: context.parameters.itemId.raw!,
            entityName: "incident",
            entitySetName: "incidents",
            context: context,
            webAPI: context.webAPI,
            files: attachments,
            isInTestHarness: this.isInTestHarness
        };

        this._root.render(React.createElement(FileUploadControl, props));
    }

    /**
     * It is called by the framework prior to a control receiving new data.
     * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as "bound" or "output"
     */
    public getOutputs(): IOutputs {
        return {};
    }

    /**
     * Called when the control is to be removed from the DOM tree. Controls should use this call for cleanup.
     * i.e. cancelling any pending remote calls, removing listeners, etc.
     */
    public destroy(): void {
        // Add code to cleanup control if necessary
        this._root.unmount();
    }
}
