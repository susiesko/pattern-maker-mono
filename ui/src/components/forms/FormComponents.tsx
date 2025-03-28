import styled from 'styled-components';

export const FormContainer = styled.div`
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  padding: ${props => props.theme.spacing.xl};
`;

export const FormTitle = styled.h2`
  color: ${props => props.theme.colors.text};
  margin-bottom: ${props => props.theme.spacing.xl};
  text-align: center;
`;

export const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing.lg};
`;

export const FormGroup = styled.div`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing.sm};
`;

export const Label = styled.label`
  font-weight: 500;
  color: ${props => props.theme.colors.text};
  font-size: ${props => props.theme.fontSizes.medium};
`;

export const Input = styled.input`
  padding: 0.75rem;
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  width: 100%;
  transition: border-color ${props => props.theme.transitions.default};

  &:focus {
    border-color: ${props => props.theme.colors.primary};
    outline: none;
  }

  &:disabled {
    background-color: ${props => props.theme.colors.disabled};
    cursor: not-allowed;
  }
`;

export const Select = styled.select`
  padding: 0.75rem;
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  width: 100%;
  transition: border-color ${props => props.theme.transitions.default};

  &:focus {
    border-color: ${props => props.theme.colors.primary};
    outline: none;
  }

  &:disabled {
    background-color: ${props => props.theme.colors.disabled};
    cursor: not-allowed;
  }
`;

export const MultiSelect = styled(Select)`
  height: auto;
  min-height: 120px;
`;

export const TextArea = styled.textarea`
  padding: 0.75rem;
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  width: 100%;
  min-height: 100px;
  resize: vertical;
  transition: border-color ${props => props.theme.transitions.default};

  &:focus {
    border-color: ${props => props.theme.colors.primary};
    outline: none;
  }

  &:disabled {
    background-color: ${props => props.theme.colors.disabled};
    cursor: not-allowed;
  }
`;

export const ErrorMessage = styled.div`
  color: ${props => props.theme.colors.error};
  font-size: ${props => props.theme.fontSizes.small};
  margin-top: ${props => props.theme.spacing.xs};
`;

export const HelperText = styled.div`
  color: ${props => props.theme.colors.lightText};
  font-size: ${props => props.theme.fontSizes.small};
  margin-top: ${props => props.theme.spacing.xs};
`;

export const ButtonGroup = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: ${props => props.theme.spacing.md};
  margin-top: ${props => props.theme.spacing.xl};
`;

export const Button = styled.button`
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  border: none;

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`;

export const PrimaryButton = styled(Button)`
  background-color: ${props => props.theme.colors.primary};
  color: white;

  &:hover:not(:disabled) {
    background-color: ${props => props.theme.colors.primaryDark};
  }
`;

export const SecondaryButton = styled(Button)`
  background-color: transparent;
  color: ${props => props.theme.colors.primary};
  border: 1px solid ${props => props.theme.colors.primary};

  &:hover:not(:disabled) {
    background-color: ${props => props.theme.colors.primary};
  }
`;

export const DangerButton = styled(Button)`
  background-color: ${props => props.theme.colors.error};
  color: white;

  &:hover:not(:disabled) {
    background-color: ${props => props.theme.colors.error};
  }
`;

export const FormRow = styled.div`
  display: flex;
  gap: ${props => props.theme.spacing.lg};

  @media (max-width: 768px) {
    flex-direction: column;
  }
`;

export const FormColumn = styled.div`
  flex: 1;
`;
