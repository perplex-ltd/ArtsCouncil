import { IInputs } from "./generated/ManifestTypes";
import * as React from "react";
import {
    DetailsList, IColumn, DetailsListLayoutMode, IDetailsHeaderProps, SelectionMode, Selection,
    DetailsRow, IDetailsListProps
} from '@fluentui/react/lib/DetailsList';
import { IRenderFunction } from '@fluentui/react/lib/Utilities';
import { Sticky, StickyPositionType } from '@fluentui/react/lib/Sticky';

import { IOrganisation, OrganisationList, OrganisationListItem } from './OrganisationList'

import { ScrollablePane } from 'office-ui-fabric-react/lib/ScrollablePane';
import { Link, Stack, Text } from 'office-ui-fabric-react';
import { GridFooter } from './GridFooter';

import DataSetInterfaces = ComponentFramework.PropertyHelper.DataSetApi;
type DataSet = ComponentFramework.PropertyTypes.DataSet;


import { StringSimilarity } from './StringSimilarity';

export interface IDetailsListGridProps {
    dataSet: ComponentFramework.PropertyTypes.DataSet;
    pcfContext: ComponentFramework.Context<IInputs>;
    organisations: IOrganisation[];
    containerWidth?: number;
    containerHeight?: number;
    isSubgrid: boolean;
    setFullScreen: (value: boolean) => void;

}

export interface IEventParticipationsGridState {

}



export class DetailsListGrid extends React.Component<
    IDetailsListGridProps,
    IEventParticipationsGridState
    > {
    private _selection: Selection;

    private _stringSimilarity: StringSimilarity;

    constructor(props: any) {
        super(props);
        this.state = {};
        this._stringSimilarity = new StringSimilarity(this.props.organisations.map(o => o.name));
    }


    /**
    * Convert our columns in a format which is accepted by DetailsList grid
    * @param columns columns available on views
    */
    private mapCRMColumnsToDetailsListColmns(columns: DataSetInterfaces.Column[]): any {
        let mappedColumn = []
        try {
            // loop thorugh all columns
            for (const c in columns) {
                const col = columns[c];
                mappedColumn.push({
                    key: c,
                    name: col.displayName,
                    fieldName: col.name,
                    minWidth: 150,
                    maxWidth: 200,
                    isResizable: true,
                    data: "string",
                    onRender: (item: any) => this._onRenderCell(item, col)
                })
            }
        } catch (error) {
            console.log("mapCRMColumnsToDetailsListColmns: " + error);
        }
        return mappedColumn;
    }
    private _onRenderCell(item: any, column: DataSetInterfaces.Column): React.ReactNode {

        //return React.createElement('span', null, item[column.name]);

        //item.raw._record.fields[column.name] // get raw field
        const record = this.props.pcfContext.parameters.dataSetGrid.records[item.key];
        if (column.isPrimary) {
            return (<Link onClick={() => this._openRecord(record.getNamedReference())}>{item[column.name]}</Link>);
        }
        switch (column.dataType) {
            case "Lookup.Simple":
                const reference = record.getValue(column.name) as ComponentFramework.EntityReference;
                return (<Link onClick={() => this._openRecord(reference)}>{reference.name}</Link>);
            default:
                return (<Text>{item[column.name]}</Text>);
        }
    }

    private _openRecord(entityReference: ComponentFramework.EntityReference) {
        this.props.pcfContext.parameters.dataSetGrid.openDatasetItem(entityReference)
    }

    public render(): JSX.Element {



        if (this.props.isSubgrid) {
            return (
                <>
                    {this._renderGrid()}
                    <GridFooter dataset={this.props.pcfContext.parameters.dataSetGrid} selectedCount={124}></GridFooter>
                </>
            )
        }

        const height = (this.props.containerHeight != null && this.props.containerHeight !== -1) ? `${this.props.containerHeight}px` : "100%";
        return (
            <Stack grow verticalFill className="container" style={{ height, width: "100%" }}>
                <Stack.Item grow className="gridContainer" >
                    <ScrollablePane scrollbarVisibility={"auto"} >
                        {this._renderGrid()}
                    </ScrollablePane>
                </Stack.Item>

                <Stack.Item>
                    <GridFooter dataset={this.props.pcfContext.parameters.dataSetGrid} selectedCount={123}></GridFooter>
                </Stack.Item>

            </Stack>

        );
    }
    private _renderGrid(): JSX.Element {
        const columnsOnView = this.props.pcfContext.parameters.dataSetGrid.columns;
        const mappedColumns = this.mapCRMColumnsToDetailsListColmns(columnsOnView);
        const items = this.props.dataSet.sortedRecordIds.slice(
            0, Math.min(this.props.dataSet.sortedRecordIds.length, this.props.dataSet.paging.totalResultCount)).map((id) => {
                const entityIn = this.props.dataSet.records[id];
                const attributes = this.props.dataSet.columns.map((column) => ({ [column.name]: entityIn.getFormattedValue(column.name) }));
                return Object.assign({
                    key: entityIn.getRecordId(),
                    raw: entityIn
                },
                    ...attributes)
            });
        return (//<MarqueeSelection selection={this._selection}>
            <DetailsList
                setKey="items"
                onRenderDetailsHeader={this._onRenderDetailsHeader}
                items={items}
                columns={mappedColumns}
                selection={this._selection}
                selectionPreservedOnEmptyClick={true}
                selectionMode={SelectionMode.none}
                layoutMode={DetailsListLayoutMode.justified}
                onRenderRow={this._onRenderRow}
                ariaLabelForSelectionColumn="Toggle selection"
                ariaLabelForSelectAllCheckbox="Toggle selection for all items"
                checkButtonAriaLabel="Row checkbox"
            />);

        //</MarqueeSelection>;
    }

    private _onRenderDetailsHeader(props: IDetailsHeaderProps | undefined, defaultRender?: IRenderFunction<IDetailsHeaderProps>): JSX.Element {
        return (
            <Sticky stickyPosition={StickyPositionType.Header} isScrollSynced={true} >
                {defaultRender!(props)}
            </Sticky>
        );
    }

    private _onRenderRow: IDetailsListProps['onRenderRow'] = props => {
        if (props) {
            let organisationName: string = "";
            if (props.item.cdi_organization) {
                organisationName = props.item.cdi_organization;
            }
            let contactId: string = props.item?.raw?._record?.fields?.cdi_contactid?.reference?.id?.guid;

            return (
                <div>

                    <DetailsRow {...props} />
                    <OrganisationList 
                        organisation={organisationName}
                        organisationList={this.props.organisations}
                        stringSimilarity={this._stringSimilarity}
                        contactId={contactId} 
                        webApi={this.props.pcfContext.webAPI} 
                        navigation={this.props.pcfContext.navigation} 
                        />
                </div>
            );
        }
        return null;
    };


}

