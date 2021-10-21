import * as React from "react";

import { PrimaryButton, Stack, MessageBar, MessageBarType, Shimmer, ShimmerElementType, Link } from 'office-ui-fabric-react';
import { List } from 'office-ui-fabric-react/lib/List';
import { StringSimilarity } from "./StringSimilarity";
const similarityThreshold = 0.8;

const textStyles: React.CSSProperties = {
    padding: 10,
    display: 'flex',
    alignItems: 'left',
    verticalAlign: 'center'
};

export interface IOrganisation {
    name: string;
    id: string;
}

export interface OrganisationListItem {
    name: string;
    similarity: number;
    accountId: string;
}
export interface OrganisationListProps {
    organisation: string;
    contactId: string;
    webApi: ComponentFramework.WebApi;
    navigation: ComponentFramework.Navigation;
    organisationList: IOrganisation[];
    stringSimilarity: StringSimilarity;
}

export interface OrganisationListState {
    isAssociated: boolean;
    infoMessage?: string;
    errorMessage?: string;
    items?: OrganisationListItem[]
}

export class OrganisationList extends React.Component<
    OrganisationListProps,
    OrganisationListState
    > {


    private listStyles: React.CSSProperties = {
        //background: DefaultPalette.themeTertiary,
        borderTop: 0,
        borderLeft: 1,
        borderRight: 1,
        borderBottom: 1,
        marginTop: 0,
        marginLeft: 20,
        marginRight: 10,
        marginBottom: 10,
        borderStyle: "solid",
        borderColor: "#edebe9",
        textAlign: "left"
    };


    constructor(props: any) {
        super(props);
        this.state = { isAssociated: false };
    }

    private _itemLoaderTimer: any;

    public componentDidMount() {
        // delay load items so the ui doesn't hang up
        this._itemLoaderTimer = setTimeout(() => {
            this.setState({ items: this._findMatchingOrganisationNames(this.props.organisation) });
        }, 1000)
    }

    public componentWillUnmount() {
        clearInterval(this._itemLoaderTimer);
    }

    public render(): JSX.Element {
        console.log("Rendering Organisation List...");
        return (
            <div style={this.listStyles}>
                {this.state.infoMessage && <MessageBar messageBarType={MessageBarType.success} isMultiline={true}>{this.state.infoMessage}</MessageBar>}
                {this.state.errorMessage && <MessageBar messageBarType={MessageBarType.error} isMultiline={true} onDismiss={() => this._resetError()}
                    dismissButtonAriaLabel="Close">{this.state.errorMessage}</MessageBar>}
                {this.state.items ?

                    !this.state.isAssociated &&
                    (this.state.items.length > 0
                        ? <List onRenderCell={this._onRenderCell} items={this.state.items} />
                        : <MessageBar>No matching organisation.</MessageBar>
                        //<span style={{ padding: 5 }}>No matching organisation found.</span>
                    )


                    :
                    <>
                        <Shimmer cellPadding="5" style={{ padding: '5px' }}
                            shimmerElements={[
                                { type: ShimmerElementType.circle },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line, width: '100px' },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line, width: '220px' },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line },
                            ]} />
                        <Shimmer cellPadding="5" style={{ padding: '5px' }}
                            shimmerElements={[
                                { type: ShimmerElementType.circle },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line, width: '100px' },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line, width: '220px' },
                                { type: ShimmerElementType.gap, width: '20px' },
                                { type: ShimmerElementType.line },
                            ]} />
                    </>
                }
            </div>
        );
    }

    private _findMatchingOrganisationNames(organisation: string): OrganisationListItem[] {
        let matches: OrganisationListItem[] = [];
        if (!organisation) return matches;
        this.props.organisationList.forEach((o: IOrganisation) => {
            let sim = this.props.stringSimilarity.calculateSimilarity(organisation, o.name);
            if (sim >= similarityThreshold) {
                matches.push({
                    name: o.name,
                    similarity: sim,
                    accountId: o.id
                });
            }
        });
        matches = matches.sort((a, b) => {
            return b.similarity - a.similarity
        });
        return matches;
    }

    private _onRenderCell = (item?: any, index?: number, isScrolling?: boolean): React.ReactNode => {
        return (
            <Stack horizontal tokens={{ padding: 5, childrenGap: 5 }}  >
                <span><PrimaryButton onClick={(e) => this._associate(e, item)} >Associate</PrimaryButton></span>
                <span style={{ ...textStyles, minWidth: 150 }}><Link onClick={() => this._openRecord(item.accountId)}>{item.name}</Link></span>
                <span style={textStyles}>{item.similarity.toLocaleString(undefined, { style: 'percent', minimumFractionDigits: 0 })} match</span>
            </Stack>
        );
    }

    private _openRecord(accountId: string) {
        const options: ComponentFramework.NavigationApi.EntityFormOptions = {
            entityName: "account",
            entityId: accountId,
            openInNewWindow: true
        };
        this.props.navigation.openForm(options);
    }


    private _associate(e: any, item: OrganisationListItem) {
        const accountId = item.accountId.replace("{", "").replace("}", "");
        const contactId = this.props.contactId.replace("{", "").replace("}", "");
        const entity =
        {
            "parentcustomerid_account@odata.bind": `/contacts(${accountId})`
        };
        this.props.webApi.updateRecord("contact", this.props.contactId, entity).then(
            () => {
                this.setState({
                    infoMessage: `Successfully associated contact with organisation.`,
                    errorMessage: undefined,
                    isAssociated: true
                })
            },
            (error) => {
                this.setState({
                    errorMessage: `Oops, something went wrong: ${error.message}.`
                })
            });
    }

    private _resetError() {
        this.setState({ errorMessage: undefined });
    }

}


