import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { Bead } from '../../types/beads';
import { useCreateInventoryMutation, useUpdateInventoryMutation } from '../../hooks/mutations/useInventoryMutations';

interface AddToInventoryModalProps {
  bead: Bead;
  onClose: () => void;
}

const QUANTITY_UNITS = [
  { value: 'unit', label: 'Units' },
  { value: 'grams', label: 'Grams' },
  { value: 'ounces', label: 'Ounces' },
  { value: 'pounds', label: 'Pounds' },
];

export const AddToInventoryModal: React.FC<AddToInventoryModalProps> = ({ bead, onClose }) => {
  const [quantity, setQuantity] = useState<string>('');
  const [quantityUnit, setQuantityUnit] = useState<string>('unit');
  const [errors, setErrors] = useState<Record<string, string>>({});
  
  const createInventoryMutation = useCreateInventoryMutation();
  const updateInventoryMutation = useUpdateInventoryMutation();

  const existingInventory = bead.user_inventory;
  const isUpdating = !!existingInventory;
  const isSubmitting = createInventoryMutation.isPending || updateInventoryMutation.isPending;

  // Pre-populate form if updating existing inventory
  useEffect(() => {
    if (existingInventory) {
      setQuantity(existingInventory.quantity.toString());
      setQuantityUnit(existingInventory.quantity_unit);
    }
  }, [existingInventory]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    setErrors({});
    
    const quantityNumber = parseFloat(quantity);
    if (!quantity || isNaN(quantityNumber) || quantityNumber <= 0) {
      setErrors({ quantity: 'Please enter a valid quantity greater than 0' });
      return;
    }

    try {
      if (isUpdating && existingInventory) {
        await updateInventoryMutation.mutateAsync({
          id: existingInventory.id,
          data: {
            quantity: quantityNumber,
            quantity_unit: quantityUnit,
          }
        });
      } else {
        await createInventoryMutation.mutateAsync({
          bead_id: bead.id,
          quantity: quantityNumber,
          quantity_unit: quantityUnit,
        });
      }
      
      onClose();
    } catch (error: any) {
      if (error.response?.data?.error) {
        setErrors({ general: 'Failed to save inventory. Please try again.' });
      } else {
        setErrors({ general: 'Failed to save inventory. Please try again.' });
      }
    }
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <ModalBackdrop onClick={handleBackdropClick}>
      <ModalContainer role="dialog" aria-modal="true">
        <ModalHeader>
          <ModalTitle>
            {isUpdating ? 'Update Inventory' : 'Add to Inventory'}
          </ModalTitle>
          <CloseButton onClick={onClose}>×</CloseButton>
        </ModalHeader>

        <ModalContent>
          <BeadInfo>
            <BeadName>{bead.name}</BeadName>
            <BeadBrand>{bead.brand.name}</BeadBrand>
            {isUpdating && existingInventory && (
              <CurrentQuantity>
                Current: {existingInventory.quantity} {existingInventory.quantity_unit}
              </CurrentQuantity>
            )}
          </BeadInfo>

          <Form onSubmit={handleSubmit}>
            {errors.general && (
              <ErrorMessage>{errors.general}</ErrorMessage>
            )}

            <FormGroup>
              <Label htmlFor="quantity">
                {isUpdating ? 'New Quantity *' : 'Quantity *'}
              </Label>
              <QuantityInput
                id="quantity"
                type="number"
                step="0.1"
                min="0.1"
                value={quantity}
                onChange={(e) => setQuantity(e.target.value)}
                placeholder="Enter quantity"
                hasError={!!errors.quantity}
              />
              {errors.quantity && (
                <FieldError>{errors.quantity}</FieldError>
              )}
            </FormGroup>

            <FormGroup>
              <Label htmlFor="unit">Unit</Label>
              <UnitSelect
                id="unit"
                value={quantityUnit}
                onChange={(e) => setQuantityUnit(e.target.value)}
              >
                {QUANTITY_UNITS.map(unit => (
                  <option key={unit.value} value={unit.value}>
                    {unit.label}
                  </option>
                ))}
              </UnitSelect>
            </FormGroup>

            <ButtonGroup>
              <CancelButton type="button" onClick={onClose}>
                Cancel
              </CancelButton>
              <SubmitButton 
                type="submit" 
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Saving...' : (isUpdating ? 'Update Inventory' : 'Add to Inventory')}
              </SubmitButton>
            </ButtonGroup>
          </Form>
        </ModalContent>
      </ModalContainer>
    </ModalBackdrop>
  );
};

// Styled Components (same as before)
const ModalBackdrop = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
`;

const ModalContainer = styled.div`
  background-color: white;
  border-radius: 8px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow: hidden;
`;

const ModalHeader = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e5e5e5;
`;

const ModalTitle = styled.h2`
  font-size: 18px;
  font-weight: 600;
  margin: 0;
`;

const CloseButton = styled.button`
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;

  &:hover {
    background-color: #f5f5f5;
  }
`;

const ModalContent = styled.div`
  padding: 20px;
`;

const BeadInfo = styled.div`
  margin-bottom: 20px;
  padding: 12px;
  background-color: #f8f9fa;
  border-radius: 4px;
`;

const BeadName = styled.h3`
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 4px 0;
`;

const BeadBrand = styled.p`
  font-size: 14px;
  color: #6c757d;
  margin: 0;
`;

const CurrentQuantity = styled.p`
  font-size: 14px;
  color: #007bff;
  margin: 4px 0 0 0;
  font-weight: 500;
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

const FormGroup = styled.div`
  display: flex;
  flex-direction: column;
  gap: 4px;
`;

const Label = styled.label`
  font-size: 14px;
  font-weight: 600;
`;

const QuantityInput = styled.input<{ hasError?: boolean }>`
  padding: 12px;
  border: 1px solid ${props => props.hasError ? '#dc3545' : '#dee2e6'};
  border-radius: 4px;
  font-size: 16px;

  &:focus {
    outline: none;
    border-color: ${props => props.hasError ? '#dc3545' : '#007bff'};
  }
`;

const UnitSelect = styled.select`
  padding: 12px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  font-size: 16px;
  background-color: white;
  cursor: pointer;

  &:focus {
    outline: none;
    border-color: #007bff;
  }
`;

const ErrorMessage = styled.div`
  background-color: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 4px;
  font-size: 14px;
`;

const FieldError = styled.span`
  color: #dc3545;
  font-size: 12px;
`;

const ButtonGroup = styled.div`
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 16px;
`;

const CancelButton = styled.button`
  padding: 12px 20px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: white;
  cursor: pointer;

  &:hover {
    background-color: #f8f9fa;
  }
`;

const SubmitButton = styled.button`
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  background-color: #28a745;
  color: white;
  font-weight: 500;
  cursor: pointer;

  &:hover:not(:disabled) {
    background-color: #218838;
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`; 