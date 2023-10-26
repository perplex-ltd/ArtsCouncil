import React from 'react';
import './App.css';
import { NeutralColors } from '@fluentui/theme';
import { Stack, Text, FontWeights } from 'office-ui-fabric-react';
import { IBasePickerSuggestionsProps, CompactPeoplePicker } from '@fluentui/react/lib/Pickers';
import { IPersonaProps } from '@fluentui/react/lib/Persona';
import { DefaultButton, PrimaryButton } from '@fluentui/react/lib/Button';
import { Dialog, DialogType } from '@fluentui/react/lib/Dialog';
import { ProgressIndicator } from '@fluentui/react/lib/ProgressIndicator';


const boldStyle = {
  root: { fontWeight: FontWeights.semibold }
};
const textStyle = {
  root: { textAlign: 'left' }
};

const suggestionProps: IBasePickerSuggestionsProps = {
  suggestionsHeaderText: 'Tech Champions',
  mostRecentlyUsedHeaderText: 'Tech Champions',
  noResultsFoundText: 'No results found',
  loadingText: 'Loading Tech Champions',
  showRemoveButtons: true,
  suggestionsAvailableAlertText: 'People Picker Suggestions available',
  suggestionsContainerAriaLabel: 'Tech Champions'
};

const dialogContentProps = {
  type: DialogType.normal,
  title: 'Progress'
};

const Xrm: Xrm.XrmStatic = window.parent.Xrm;

export const App: React.FunctionComponent = () => {

  const [isAssignButtonDisabled, setIsAssignButtonDisabled] = React.useState(true);
  const [hideProgressDialog, setHideProgressDialog] = React.useState(true);
  const [percentComplete, setPercentComplete] = React.useState<number | undefined>(undefined);
  const [selectedTCId, setSelectedTCId] = React.useState<string | undefined>();

  //var selectedPersonId: string | null | undefined;
  const leads = getLeads();

  const _assignClicked = async () => {
    debugger;
    if (selectedTCId) {
      setHideProgressDialog(false);
      setPercentComplete(0);
      try {
        for (let i = 0; i < leads.length; i++) {
          let lead = leads[i];
          await assignLead(lead, selectedTCId);
          setPercentComplete((i + 1) / leads.length);
        }
      } catch (e) {
        Xrm.Navigation.openAlertDialog({ text: (e as Error)?.message, title: "Error" });
      } finally {
        if (Xrm) {
          window.close();
        } else {
          alert("I would close this window now...");
          setHideProgressDialog(true);
        }
      }
    }
  }

  const _cancelClicked = (): void => { window.close(); }

  const loadTechChampionsPromise: Promise<IPersonaProps[]> = new Promise<IPersonaProps[]>(function (resolve) {
    if (Xrm) {
      const fetchXml = `
      <fetch>
  <entity name="systemuser">
    <attribute name="fullname" />
    <attribute name="systemuserid" />
    <filter>
      <condition attribute="isdisabled" operator="eq" value="0" />
      <condition entityname="t" attribute="name" operator="eq" value="Digital Culture Network" />
    </filter>
    <order attribute="fullname" />
    <link-entity name="teammembership" from="systemuserid" to="systemuserid" link-type="inner" alias="tm" intersect="true">
      <link-entity name="team" from="teamid" to="teamid" link-type="inner" alias="t" intersect="true">
        <attribute name="name" />
      </link-entity>
    </link-entity>
  </entity>
</fetch>`;
      //Xrm.WebApi.online.retrieveMultipleRecords("systemuser", "?$select=fullname,systemuserid&$filter=contains(title, 'Tech%20Champion') and  isdisabled eq false&$orderby=fullname asc").then(
      Xrm.WebApi.online.retrieveMultipleRecords("systemuser", "?fetchXml=" + fetchXml).then(
        function success(results) {
          let people = [];
          for (var i = 0; i < results.entities.length; i++) {
            people.push({
              text: results.entities[i]["fullname"],
              id: results.entities[i]["systemuserid"]
            });
          }
          resolve(people);
        },
        function (error) {
          Xrm.Navigation.openAlertDialog({ text: error.message, title: "Error" });
        }
      );
    } else {
      resolve([
        { text: "Debug", id: "0" },
        { text: "Debug", id: "1" },
        { text: "Debug", id: "2" },
        { text: "Debug", id: "3" },
        { text: "Debug", id: "4" },
        { text: "Debug", id: "5" },
        { text: "Debug", id: "6" },
        { text: "Debug", id: "7" },
        { text: "Debug", id: "8" },
        { text: "Debug", id: "9" },
        { text: "Debug", id: "10" },
        { text: "Debug", id: "11" }
      ]);
    }
  });

  const techChampionList = (): Promise<IPersonaProps[]> => {
    return loadTechChampionsPromise.then((peopleList: IPersonaProps[]) => { return peopleList });
  }

  const picker = React.useRef(null);

  const onEmptyResolveSuggestions = (): IPersonaProps[] | Promise<IPersonaProps[]> => {
    return techChampionList();
  };

  const onResolveSuggestions = (filterText: string): IPersonaProps[] | Promise<IPersonaProps[]> => {
    if (filterText) {
      return techChampionList().then((peopleList: IPersonaProps[]) => {
        return peopleList.filter(item => doesTextStartWith(item.text as string, filterText));
      })
    } else {
      return techChampionList();
    }
  };

  const onChange = (items?: IPersonaProps[]): void => {
    if (items && items.length === 1) {
      setSelectedTCId(items[0].id);
      setIsAssignButtonDisabled(false);
    } else {
      setSelectedTCId(undefined);
      setIsAssignButtonDisabled(true);
    }
  }


  return (
    <Stack
      horizontalAlign="start"
      verticalAlign="start"

      styles={{
        root: {
          //alignItems: 'start',
          maxWidth: '600px',
          padding: '10px',
          margin: '20px auto',
          textAlign: 'center',
          color: '#605e5c',
          backgroundColor: '#fff'
        }
      }}
      tokens={{childrenGap: 25}}
      //gap={25}
    >
      <Text variant="xxLarge" styles={boldStyle}>
        Assign Leads
      </Text>
      <Text variant="medium" styles={textStyle} >You are about to assign {leads.length} {leads.length == 1 ? "lead" : "leads"} to a Tech Champion. Once you click <i>Assign</i>, CRM will send out emails to the leads.</Text>

      <Stack horizontal tokens={{childrenGap: 15}}
       styles={{
        root: {
          alignItems: 'start',
          verticalAlign: 'center',
          width: '100%',
        }
      }
      }>
        <Stack.Item align="center">
          <Text>Tech Champion</Text>
        </Stack.Item>
        <Stack.Item grow align="center">
          <CompactPeoplePicker
            // eslint-disable-next-line react/jsx-no-bind
            onResolveSuggestions={onResolveSuggestions}
            // eslint-disable-next-line react/jsx-no-bind
            onEmptyResolveSuggestions={onEmptyResolveSuggestions}
            getTextFromItem={getTextFromItem}
            pickerSuggestionsProps={suggestionProps}
            //selectionAriaLabel={'Selected contacts'}
            removeButtonAriaLabel={'Remove'}
            className={'ms-PeoplePicker'}
            onChange={onChange}
            componentRef={picker}
            resolveDelay={300}
            itemLimit={1}
          />
        </Stack.Item>
      </Stack>
      <div />
      <Stack horizontal 
        //gap={15} 
        horizontalAlign="end"
        tokens={{childrenGap: 15}}
        styles={{
          root: {
            padding: 10,
            width: '100%',
            backgroundColor: NeutralColors.gray20,
          }
        }}>
        <PrimaryButton text="Assign" onClick={_assignClicked} allowDisabledFocus disabled={isAssignButtonDisabled} />
        <DefaultButton text="Cancel" onClick={_cancelClicked} allowDisabledFocus />
      </Stack>
      <Dialog
        hidden={hideProgressDialog}
        dialogContentProps={dialogContentProps}
        modalProps={{
          isBlocking: true,
          isDarkOverlay: true
        }}
      >
        <span>
          <ProgressIndicator label="Assigning leads" description="We're busy assigning the leads to Tech Champions" percentComplete={percentComplete} />
        </span>
      </Dialog>
    </Stack>
  );


};

function doesTextStartWith(text: string, filterText: string): boolean {
  return text.toLowerCase().indexOf(filterText.toLowerCase()) === 0;
}

function getTextFromItem(persona: IPersonaProps): string {
  return persona.text as string;
}

function getLeads(): string[] {
  const params = new URLSearchParams(window.location.search);
  const data = params.get("data");
  if (data) {
    return JSON.parse(data);
  } else {
    return [];
  }
}

async function assignLead(leadId: string, techChampionId: string): Promise<void> {
  console.log("assignLead('" + leadId + "', '" + techChampionId + "') called");
  if (Xrm) {
    var parameters: any = {};
    var entity: any = {};
    entity.id = leadId;
    entity.entityType = "incident";
    parameters.entity = entity;
    var techchampion: any = {};
    techchampion.systemuserid = techChampionId; //Delete if creating new record 
    techchampion["@odata.type"] = "Microsoft.Dynamics.CRM.systemuser";
    parameters.TechChampion = techchampion;

    var ace_AssignEventLeadCaseRequest = {
      entity: parameters.entity,
      TechChampion: parameters.TechChampion,

      getMetadata: function () {
        return {
          boundParameter: "entity",
          parameterTypes: {
            "entity": {
              "typeName": "mscrm.incident",
              "structuralProperty": 5
            },
            "TechChampion": {
              "typeName": "mscrm.systemuser",
              "structuralProperty": 5
            }
          },
          operationType: 0,
          operationName: "ace_AssignEventLeadCase"
        };
      }
    };

    Xrm.WebApi.online.execute(ace_AssignEventLeadCaseRequest).then(
      function success(result) {
        if (result.ok) {
          return;
        }
      },
      function (error) {
        throw (error);
      }
    );
  } else {
    await sleep(500);
  }
}

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
