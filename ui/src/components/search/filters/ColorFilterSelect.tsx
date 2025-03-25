import { ChangeEvent } from 'react';
import useBeadColorsQuery from '../../../hooks/queries/useBeadColorsQuery';
import { StyledSelect } from '../../styledComponents';

interface ColorFilterSelectionProps {
  onChange: (e: ChangeEvent<HTMLSelectElement>) => void;
  value: string;
}

const ColorFilterSelect = ({ onChange, value }: ColorFilterSelectionProps) => {
  const { data, isLoading } = useBeadColorsQuery();

  return (
    <>
      <label htmlFor="color">Color:</label>
      <StyledSelect name="color" id="color" onChange={onChange} value={value} disabled={isLoading}>
        <option value="">All</option>
        {data?.map(color => (
          <option key={color.id} value={color.id.toString()}>
            {color.name}
          </option>
        ))}
      </StyledSelect>
    </>
  );
};

export default ColorFilterSelect;
