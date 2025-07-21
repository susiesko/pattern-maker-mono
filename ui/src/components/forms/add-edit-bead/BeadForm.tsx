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
  const { data: shapes, isLoading: shapesLoading } = useBeadTypesQuery(); // Types query now returns shapes
  const { data: colors, isLoading: colorsLoading } = useBeadColorsQuery();
  const { data: finishes, isLoading: finishesLoading } = useBeadFinishesQuery();

  const [formData, setFormData] = useState({
    name: '',
    brand_product_code: '',
    brand_id: '',
    shape: '',
    size: '',
    color_group: '',
    finish: '',
    glass_group: '',
    dyed: '',
    galvanized: '',
    plating: '',
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
        shape: bead.shape || '',
        size: bead.size || '',
        color_group: bead.color_group || '',
        finish: bead.finish || '',
        glass_group: bead.glass_group || '',
        dyed: bead.dyed || '',
        galvanized: bead.galvanized || '',
        plating: bead.plating || '',
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

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    // Required fields
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.brand_id) {
      newErrors.brand_id = 'Brand is required';
    }

    if (!formData.size) {
      newErrors.size = 'Size is required';
    }

    if (!formData.color_group) {
      newErrors.color_group = 'Color group is required';
    }

    if (!formData.finish) {
      newErrors.finish = 'Finish is required';
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
          shape: formData.shape || undefined,
          size: formData.size || undefined,
          color_group: formData.color_group || undefined,
          finish: formData.finish || undefined,
          glass_group: formData.glass_group || undefined,
          dyed: formData.dyed || undefined,
          galvanized: formData.galvanized || undefined,
          plating: formData.plating || undefined,
        });
      } else {
        // Create new bead
        await createMutation.mutateAsync({
          name: formData.name,
          brand_product_code: formData.brand_product_code || undefined,
          image: formData.image || undefined,
          brand_id: parseInt(formData.brand_id),
          shape: formData.shape || undefined,
          size: formData.size || undefined,
          color_group: formData.color_group || undefined,
          finish: formData.finish || undefined,
          glass_group: formData.glass_group || undefined,
          dyed: formData.dyed || undefined,
          galvanized: formData.galvanized || undefined,
          plating: formData.plating || undefined,
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
    brandsLoading || sizesLoading || shapesLoading || colorsLoading || finishesLoading;

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
              <Label htmlFor="size">Size *</Label>
              <Select
                id="size"
                name="size"
                value={formData.size}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a size</option>
                {sizes?.map(size => (
                  <option key={size} value={size}>
                    {size}
                  </option>
                ))}
              </Select>
              {errors.size && <ErrorMessage>{errors.size}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="color_group">Color Group *</Label>
              <Select
                id="color_group"
                name="color_group"
                value={formData.color_group}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a color group</option>
                {colors?.map(color => (
                  <option key={color} value={color}>
                    {color}
                  </option>
                ))}
              </Select>
              {errors.color_group && <ErrorMessage>{errors.color_group}</ErrorMessage>}
            </FormGroup>
          </FormColumn>
        </FormRow>

        <FormRow>
          <FormColumn>
            <FormGroup>
              <Label htmlFor="finish">Finish *</Label>
              <Select
                id="finish"
                name="finish"
                value={formData.finish}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a finish</option>
                {finishes?.map(finish => (
                  <option key={finish} value={finish}>
                    {finish}
                  </option>
                ))}
              </Select>
              {errors.finish && <ErrorMessage>{errors.finish}</ErrorMessage>}
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="glass_group">Glass Group</Label>
              <Select
                id="glass_group"
                name="glass_group"
                value={formData.glass_group}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select a glass group</option>
                {/* Assuming glass groups are fetched or derived */}
                <option value="A">Group A</option>
                <option value="B">Group B</option>
                <option value="C">Group C</option>
              </Select>
            </FormGroup>
          </FormColumn>

          <FormColumn>
            <FormGroup>
              <Label htmlFor="dyed">Dyed</Label>
              <Select
                id="dyed"
                name="dyed"
                value={formData.dyed}
                onChange={handleInputChange}
                disabled={isSubmitting}
              >
                <option value="">Select if dyed</option>
                <option value="Yes">Yes</option>
                <option value="No">No</option>
              </Select>
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
