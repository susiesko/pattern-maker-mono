import { ChangeEvent } from 'react';
import useBeadFinishesQuery from '../../../hooks/queries/useBeadFinishesQuery';
import { StyledSelect } from '../../styledComponents';

interface FinishFilterSelectionProps {
  onChange: (e: ChangeEvent<HTMLSelectElement>) => void;
  value: string;
}

function FinishFilterSelect({ onChange, value }: FinishFilterSelectionProps) {
  const { data, isLoading } = useBeadFinishesQuery();

  return (
    <>
      <label htmlFor="finish">Finish:</label>
      <StyledSelect
        name="finish"
        id="finish"
        onChange={onChange}
        value={value}
        disabled={isLoading}
      >
        <option value="">All</option>
        {data?.map(finish => (
          <option key={finish.id} value={finish.id.toString()}>
            {finish.name}
          </option>
        ))}
      </StyledSelect>
    </>
  );
}

export default FinishFilterSelect;
