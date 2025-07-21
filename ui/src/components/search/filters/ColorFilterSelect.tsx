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
      <label htmlFor="color_group">Color:</label>
      <StyledSelect name="color_group" id="color_group" onChange={onChange} value={value} disabled={isLoading}>
        <option value="">All</option>
        {data?.map(color => (
          <option key={color} value={color}>
            {color}
          </option>
        ))}
      </StyledSelect>
    </>
  );
};

export default ColorFilterSelect;
