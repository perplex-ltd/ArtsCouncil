import * as React from 'react';
import { Stack } from '@fluentui/react/lib/Stack';
import { IconButton } from '@fluentui/react/lib/Button';

type DataSet = ComponentFramework.PropertyTypes.DataSet;

export interface IGridFooterProps {
    dataset: DataSet;
    selectedCount: number;
}

const usePaging = (dataset: DataSet) => {    
      
    const [firstItemNumber, setFirstItemNumber] = React.useState<number>(0);
    const [lastItemNumber, setLastItemNumber] = React.useState<number>();
    const [totalRecords, setTotalRecords] = React.useState<number>();
    const [currentPage, setCurrentPage] = React.useState<number>(0);
    const [pageSize, setPageSize] = React.useState<number>(0);    
               

    React.useEffect(() => {
        if(!dataset.paging.hasPreviousPage){ //first page
            setPageSize(dataset.sortedRecordIds.length);
            setCurrentPage(1);
            setTotalRecords(dataset.paging.totalResultCount);      
        }               
        setFirstItemNumber((currentPage-1) * pageSize + 1);
        setLastItemNumber((currentPage-1) * pageSize + dataset.sortedRecordIds.length )       
    }, [dataset]);

  

    function moveToFirst(){        
        setCurrentPage(1);
        (dataset.paging as any).loadExactPage(1);
    }

    function movePrevious(){        
        const newPage = currentPage-1;
        setCurrentPage(newPage);
        (dataset.paging as any).loadExactPage(newPage);        
       
    }

    function moveNext(){        
        const newPage = currentPage+1;
        setCurrentPage(newPage);
        (dataset.paging as any).loadExactPage(newPage);                
    }   

    return {       
        
        currentPage,
        firstItemNumber, 
        lastItemNumber, 
        totalRecords, 
        moveToFirst, 
        movePrevious,
        moveNext,       

    }
}

export const GridFooter = ({dataset, selectedCount} : IGridFooterProps) => {
    const {             
        currentPage,
        firstItemNumber, 
        lastItemNumber, 
        totalRecords, 
        moveToFirst, 
        movePrevious,
        moveNext
    } = usePaging(dataset);
    
    return (<Stack grow horizontal horizontalAlign="space-between" >
    <Stack.Item className="Footer">
        <Stack grow horizontal horizontalAlign="space-between" >
            <Stack.Item grow={1} align="center" >{firstItemNumber} - {lastItemNumber}{ ((totalRecords??-1) >= 0) ? totalRecords : null}</Stack.Item>
            <Stack.Item grow={1} align="center" className="FooterRight">
                <IconButton className="FooterIcon" iconProps={{ iconName: "DoubleChevronLeft"}} onClick={moveToFirst} disabled={!dataset.paging.hasPreviousPage}/>
                <IconButton className="FooterIcon" iconProps={{ iconName: "ChevronLeft"}} onClick={movePrevious} disabled={!dataset.paging.hasPreviousPage}/>
                <span >Page {currentPage}</span>
                <IconButton className="FooterIcon" iconProps={{ iconName: "ChevronRight" }} onClick={moveNext} disabled={!dataset.paging.hasNextPage}/>
            </Stack.Item>
        </Stack>
    </Stack.Item>
</Stack>)
}