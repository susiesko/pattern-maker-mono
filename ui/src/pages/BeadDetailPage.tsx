import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import styled from 'styled-components';
import { useBeadQuery } from '../hooks/queries/useBeadQuery';
import { AddToInventoryModal } from '../components/modals';

const BeadDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const beadId = id ? parseInt(id) : null;
  const { data: bead, isLoading, error } = useBeadQuery(beadId);
  const [showAddToInventoryModal, setShowAddToInventoryModal] = useState(false);

  if (isLoading) {
    return (
      <Container>
        <div>Loading bead details...</div>
      </Container>
    );
  }

  if (error || !bead) {
    return (
      <Container>
        <div>Failed to load bead details. Please try again.</div>
      </Container>
    );
  }

  const handleBackClick = () => {
    navigate('/beads');
  };

  const handleEditClick = () => {
    navigate(`/beads/edit/${bead.id}`);
  };

  const handleAddToInventory = () => {
    setShowAddToInventoryModal(true);
  };

  const hasInventory = !!bead.user_inventory;

  return (
    <Container>
      <Header>
        <BackButton onClick={handleBackClick}>
          ← Back to Catalog
        </BackButton>
        <HeaderActions>
          <AddToInventoryButton onClick={handleAddToInventory}>
            {hasInventory ? 'Update Inventory' : 'Add to Inventory'}
          </AddToInventoryButton>
          <EditButton onClick={handleEditClick}>
            Edit Bead
          </EditButton>
        </HeaderActions>
      </Header>

      <Content>
        <ImageSection>
          <ImageContainer>
            {bead.image && bead.image.trim() ? (
              <BeadImage src={`/bead-images/${bead.image}`} alt={bead.name} />
            ) : (
              <PlaceholderImage>
                <PlaceholderText>No Image Available</PlaceholderText>
              </PlaceholderImage>
            )}
          </ImageContainer>
        </ImageSection>

        <DetailsSection>
          <BeadTitle>{bead.name}</BeadTitle>
          
          {bead.brand_product_code && (
            <ProductCode>Product Code: {bead.brand_product_code}</ProductCode>
          )}

          <BrandInfo>
            <BrandLabel>Brand:</BrandLabel>
            <BrandName>{bead.brand.name}</BrandName>
          </BrandInfo>

          <DetailGrid>
            <DetailItem>
              <DetailLabel>Shape:</DetailLabel>
              <DetailValue>{bead.shape || 'Not specified'}</DetailValue>
            </DetailItem>

            <DetailItem>
              <DetailLabel>Size:</DetailLabel>
              <DetailValue>{bead.size || 'Not specified'}</DetailValue>
            </DetailItem>

            {bead.color_group && (
              <DetailItem>
                <DetailLabel>Color Group:</DetailLabel>
                <DetailValue>
                  <ColorTag>{bead.color_group}</ColorTag>
                </DetailValue>
              </DetailItem>
            )}

            {bead.finish && (
              <DetailItem>
                <DetailLabel>Finish:</DetailLabel>
                <DetailValue>
                  <FinishTag>{bead.finish}</FinishTag>
                </DetailValue>
              </DetailItem>
            )}

            {bead.glass_group && (
              <DetailItem>
                <DetailLabel>Glass Group:</DetailLabel>
                <DetailValue>
                  <GlassTag>{bead.glass_group}</GlassTag>
                </DetailValue>
              </DetailItem>
            )}

            {bead.dyed && (
              <DetailItem>
                <DetailLabel>Dyed:</DetailLabel>
                <DetailValue>{bead.dyed}</DetailValue>
              </DetailItem>
            )}

            {bead.galvanized && (
              <DetailItem>
                <DetailLabel>Galvanized:</DetailLabel>
                <DetailValue>{bead.galvanized}</DetailValue>
              </DetailItem>
            )}

            {bead.plating && (
              <DetailItem>
                <DetailLabel>Plating:</DetailLabel>
                <DetailValue>{bead.plating}</DetailValue>
              </DetailItem>
            )}
          </DetailGrid>
        </DetailsSection>
      </Content>

      {showAddToInventoryModal && (
        <AddToInventoryModal
          bead={bead}
          onClose={() => setShowAddToInventoryModal(false)}
        />
      )}
    </Container>
  );
};

export default BeadDetailPage;

// Styled Components
const Container = styled.div`
  min-height: 100vh;
  background-color: ${props => props.theme.colors.secondary};
`;

const Header = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-bottom: 1px solid ${props => props.theme.colors.border};
  padding: ${props => props.theme.spacing.lg};
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const BackButton = styled.button`
  background: none;
  border: none;
  color: ${props => props.theme.colors.primary};
  font-size: ${props => props.theme.fontSizes.medium};
  cursor: pointer;
  padding: ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.secondary};
  }
`;

const HeaderActions = styled.div`
  display: flex;
  gap: ${props => props.theme.spacing.md};
`;

const AddToInventoryButton = styled.button`
  background-color: ${props => props.theme.colors.success};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.sm} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.successDark};
    transform: translateY(-1px);
  }
`;

const EditButton = styled.button`
  background-color: ${props => props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.sm} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
    transform: translateY(-1px);
  }
`;

const Content = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: ${props => props.theme.spacing.xl};
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: ${props => props.theme.spacing.xl};

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
    gap: ${props => props.theme.spacing.lg};
  }
`;

const ImageSection = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.small};
  padding: ${props => props.theme.spacing.lg};
`;

const ImageContainer = styled.div`
  width: 100%;
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: ${props => props.theme.colors.secondary};
  border-radius: ${props => props.theme.borderRadius.medium};
  overflow: hidden;
`;

const BeadImage = styled.img`
  max-width: 100%;
  max-height: 100%;
  object-fit: cover;
`;

const PlaceholderImage = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: ${props => props.theme.colors.disabled};
  color: ${props => props.theme.colors.lightText};
`;

const PlaceholderText = styled.span`
  font-size: ${props => props.theme.fontSizes.medium};
  text-align: center;
`;

const DetailsSection = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.small};
  padding: ${props => props.theme.spacing.xl};
`;

const BeadTitle = styled.h1`
  font-size: ${props => props.theme.fontSizes.xlarge};
  font-weight: 700;
  color: ${props => props.theme.colors.text};
  margin: 0 0 ${props => props.theme.spacing.md} 0;
  line-height: 1.2;
`;

const ProductCode = styled.p`
  font-size: ${props => props.theme.fontSizes.medium};
  color: ${props => props.theme.colors.lightText};
  font-family: monospace;
  background-color: ${props => props.theme.colors.secondary};
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  display: inline-block;
  margin: 0 0 ${props => props.theme.spacing.lg} 0;
`;

const BrandInfo = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing.sm};
  margin-bottom: ${props => props.theme.spacing.xl};
  padding-bottom: ${props => props.theme.spacing.lg};
  border-bottom: 1px solid ${props => props.theme.colors.border};
`;

const BrandLabel = styled.span`
  font-size: ${props => props.theme.fontSizes.medium};
  color: ${props => props.theme.colors.lightText};
`;

const BrandName = styled.span`
  font-size: ${props => props.theme.fontSizes.large};
  font-weight: 600;
  color: ${props => props.theme.colors.primary};
`;

const DetailGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: ${props => props.theme.spacing.lg};
`;

const DetailItem = styled.div`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing.xs};
`;

const DetailLabel = styled.span`
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 600;
  color: ${props => props.theme.colors.lightText};
  text-transform: uppercase;
  letter-spacing: 0.05em;
`;

const DetailValue = styled.span`
  font-size: ${props => props.theme.fontSizes.medium};
  color: ${props => props.theme.colors.text};
`;

const ColorTag = styled.span`
  background-color: ${props => props.theme.colors.primary};
  color: white;
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 500;
`;

const FinishTag = styled.span`
  background-color: ${props => props.theme.colors.success};
  color: white;
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 500;
`;

const GlassTag = styled.span`
  background-color: ${props => props.theme.colors.warning};
  color: white;
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 500;
`; 