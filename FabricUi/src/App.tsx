import React from 'react';
import { Stack, Text, Link, FontWeights } from 'office-ui-fabric-react';
import { IBasePickerSuggestionsProps, NormalPeoplePicker, ValidationState } from '@fluentui/react/lib/Pickers';

const boldStyle = {
  root: { fontWeight: FontWeights.semibold }
};
const textStyle = {
  root: { textAlign: 'left' }
};
export const App: React.FunctionComponent = () => {
  return (
    <Stack
      horizontalAlign="start"
      verticalAlign="start"
      verticalFill
      styles={{
        root: {
          alignItems: 'start',
          width: '400px',
          margin: '0 auto',
          textAlign: 'center',
          color: '#605e5c'
        }
      }}
      gap={15}
    >
      <Text variant="xxLarge" styles={boldStyle}>
        Assign Leads
      </Text>
      <Text variant="medium" styles={textStyle} >You are about to assign 12 leads to a Tech Champion. Once you click <i>Assign</i>, CRM will send out emails to the leads.</Text>
      
      <Stack horizontal gap={15} styles={{
        root: {
          alignItems: 'start'}}
        }>
        <Text>Tech Champion</Text>
        <Text>Input control placeholder</Text>
      </Stack>

    </Stack>
  );
};
