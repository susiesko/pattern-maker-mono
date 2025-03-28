// noinspection ES6PreferShortImport

import { useState, useEffect, FormEvent, ChangeEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bead } from '../../../types/beads';
import {
  useBeadBrandsQuery,
  useBeadSizesQuery,
  useBeadTypesQuery,
  useBeadColorsQuery,
  useBeadFinishesQuery,
} from '../../../hooks/queries';
import { useCreateBeadMutation, useUpdateBeadMutation } from '../../../hooks/mutations';
import {
  FormContainer,
  FormTitle,
  Form,
  FormGroup,
  Label,
  Input,
  Select,
  MultiSelect,
  ErrorMessage,
  HelperText,
  ButtonGroup,
  PrimaryButton,
  SecondaryButton,
  FormRow,
  FormColumn,
} from '../../../components/forms/FormComponents';

interface BeadFormProps {
  bead?: Bead;
  isEdit?: boolean;
}

const BeadForm = ({ bead, isEdit = false }: BeadFormProps) => {
  const navigate = useNavigate();
  const createMutation = useCreateBeadMutation();
  const updateMutation = useUpdateBeadMutation();

  // Fetch all the necessary data for dropdowns
  const { data: brands, isLoading: brandsLoading } = useBeadBrandsQuery();
  const { data: sizes, isLoading: sizesLoading } = useBeadSizesQuery();
  const { data: types, isLoading: typesLoading } = useBeadTypesQuery();
  const { data: colors, isLoading: colorsLoading } = useBeadColorsQuery();
  const { data: finishes, isLoading: finishesLoading } = useBeadFinishesQuery();

  const [formData, setFormData] = useState({
    name: '',
    brand_product_code: '',
    brand_id: '',
    size_id: '',
    type_id: '',
    color_ids: [] as string[],
    finish_ids: [] as string[],
    image: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // If editing, populate the form with the bead data
  useEffect(() => {
    if (isEdit && bead) {
      setFormData({
        name: bead.name,
        brand_product_code: bead.brand_product_code || '',
        brand_id: bead.brand.id.toString(),
        size_id: bead.size.id.toString(),
        type_id: bead.type.id.toString(),
        color_ids: bead.colors.map(color => color.id.toString()),
        finish_ids: bead.finishes.map(finish => finish.id.toString()),
        image: bead.image || '',
      });
    }
  }, [isEdit, bead]);

  const handleInputChange = (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));

    // Clear error for this field if it exists
    if (errors[name]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  const handleMultiSelectChange = (e: ChangeEvent<HTMLSelectElement>) => {
    const { name } = e.target;
    const selectedOptions = Array.from(e.target.selectedOptions).map(option => option.value);

    setFormData(prev => ({
      ...prev,
      [name]: selectedOptions,
    }));

    // Clear error for this field if it exists
    if (errors[name]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    // Required fields
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.brand_id) {
      newErrors.brand_id = 'Brand is required';
    }

    if (!formData.size_id) {
      newErrors.size_id = 'Size is required';
    }

    if (!formData.type_id) {
      newErrors.type_id = 'Type is required';
    }

    if (formData.color_ids.length === 0) {
      newErrors.color_ids = 'At least one color must be selected';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);

    try {
      if (isEdit && bead) {
        // Update existing bead
        await updateMutation.mutateAsync({
          id: bead.id,
          name: formData.name,
          brand_product_code: formData.brand_product_code || undefined,
          image: formData.image || undefined,
          brand_id: parseInt(formData.brand_id),
          size_id: parseInt(formData.size_id),
          type_id: parseInt(formData.type_id),
          color_ids: formData.color_ids.map(id => parseInt(id)),
          finish_ids: formData.finish_ids.map(id => parseInt(id)),
        });
      } else {
        // Create new bead
        await createMutation.mutateAsync({
          name: formData.name,
          brand_product_code: formData.brand_product_code || undefined,
          image: formData.image || undefined,
          brand_id: parseInt(formData.brand_id),
          size_id: parseInt(formData.size_id),
          type_id: parseInt(formData.type_id),
          color_ids: formData.color_ids.map(id => parseInt(id)),
          finish_ids: formData.finish_ids.map(id => parseInt(id)),
        });
      }

      // Navigate back to the bead catalog
      navigate('/beads');
    } catch (error) {
      console.error('Error saving bead:', error);
      setErrors({
        form: 'An error occurred while saving the bead. Please try again.',
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancel = () => {
    navigate('/beads');
  };

  const isLoading =
    brandsLoading || sizesLoading || typesLoading || colorsLoading || finishesLoading;

  if (isLoading) {
    return <FormContainer>Loading form data...</FormContainer>;
  }

  return (
    <FormContainer>
      <FormTitle>{isEdit ? 'Edit Bead' : 'Add New Bead'}</FormTitle>

      {errors.form && <ErrorMessage>{errors.form}</ErrorMessage>}

      <Form onSubmit={handleSubmit}>
        <FormRow>
          <FormColumn>
            <FormGroup>
              <Label htmlFor="name">Name *</Label>
              <Input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleInputChange}
                disabled={isSubmitting}
              />
              {errors.name && <ErrorMessage>{errors.name}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="brand_product_code">Product Code</Label>
              <Input
                type="text"
                id="brand_product_code"
                name="brand_product_code"
                value={formData.brand_product_code}
                onChange={handleInputChange}
                disabled={isSubmitting}
              />
              <HelperText>The manufacturer's product code</HelperText>
            </FormGroup>
          </FormColumn>
        </FormRow>

        <FormRow>
          <FormColumn>
            <FormGroup>
              <Label htmlFor="brand_id">Brand *</Label>
              <Select
                id="brand_id"
                name="brand_id"
                value={formData.brand_id}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a brand</option>
                {brands?.map(brand => (
                  <option key={brand.id} value={brand.id}>
                    {brand.name}
                  </option>
                ))}
              </Select>
              {errors.brand_id && <ErrorMessage>{errors.brand_id}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="size_id">Size *</Label>
              <Select
                id="size_id"
                name="size_id"
                value={formData.size_id}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a size</option>
                {sizes?.map(size => (
                  <option key={size.id} value={size.id}>
                    {size.size}
                  </option>
                ))}
              </Select>
              {errors.size_id && <ErrorMessage>{errors.size_id}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="type_id">Type *</Label>
              <Select
                id="type_id"
                name="type_id"
                value={formData.type_id}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a type</option>
                {types?.map(type => (
                  <option key={type.id} value={type.id}>
                    {type.name}
                  </option>
                ))}
              </Select>
              {errors.type_id && <ErrorMessage>{errors.type_id}</ErrorMessage>}
            </FormGroup>
          </FormColumn>
        </FormRow>

        <FormRow>
          <FormColumn>
            <FormGroup>
              <Label htmlFor="color_ids">Colors *</Label>
              <MultiSelect
                id="color_ids"
                name="color_ids"
                multiple
                value={formData.color_ids}
                onChange={handleMultiSelectChange}
                disabled={isSubmitting}
              >
                {colors?.map(color => (
                  <option key={color.id} value={color.id}>
                    {color.name}
                  </option>
                ))}
              </MultiSelect>
              <HelperText>Hold Ctrl/Cmd to select multiple colors</HelperText>
              {errors.color_ids && <ErrorMessage>{errors.color_ids}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="finish_ids">Finishes</Label>
              <MultiSelect
                id="finish_ids"
                name="finish_ids"
                multiple
                value={formData.finish_ids}
                onChange={handleMultiSelectChange}
                disabled={isSubmitting}
              >
                {finishes?.map(finish => (
                  <option key={finish.id} value={finish.id}>
                    {finish.name}
                  </option>
                ))}
              </MultiSelect>
              <HelperText>Hold Ctrl/Cmd to select multiple finishes</HelperText>
            </FormGroup>
          </FormColumn>
        </FormRow>

        <FormGroup>
          <Label htmlFor="image">Image URL</Label>
          <Input
            type="text"
            id="image"
            name="image"
            value={formData.image}
            onChange={handleInputChange}
            disabled={isSubmitting}
          />
          <HelperText>URL to an image of the bead</HelperText>
        </FormGroup>

        <ButtonGroup>
          <SecondaryButton type="button" onClick={handleCancel} disabled={isSubmitting}>
            Cancel
          </SecondaryButton>
          <PrimaryButton type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Saving...' : isEdit ? 'Update Bead' : 'Create Bead'}
          </PrimaryButton>
        </ButtonGroup>
      </Form>
    </FormContainer>
  );
};

export default BeadForm;
