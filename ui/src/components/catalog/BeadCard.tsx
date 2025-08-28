import React, { memo, useState } from 'react';
import styled from 'styled-components';
import { Bead } from '../../types/beads';
import { AddToInventoryModal } from '../modals';

// Styled Components
const CardContainer = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.small};
  overflow: hidden;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  
  &:hover {
    box-shadow: ${props => props.theme.shadows.medium};
    transform: translateY(-2px);
  }
`;

const ImageContainer = styled.div`
  height: 200px;
  background-color: ${props => props.theme.colors.secondary};
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid ${props => props.theme.colors.border};
  position: relative;
`;

const BeadImage = styled.img`
  max-width: 100%;
  max-height: 100%;
  object-fit: cover;
  border-radius: ${props => props.theme.borderRadius.small};
`;

const PlaceholderImage = styled.div`
  width: 80px;
  height: 80px;
  background-color: ${props => props.theme.colors.disabled};
  border-radius: ${props => props.theme.borderRadius.small};
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${props => props.theme.colors.lightText};
  font-size: ${props => props.theme.fontSizes.small};
  
  &::before {
    content: "No Image";
  }
`;

const InventoryButtonOverlay = styled.div`
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 10;
`;

const InventoryButton = styled.button<{ hasInventory: boolean }>`
  background-color: ${props => props.hasInventory ? props.theme.colors.success : props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  position: relative;
  box-shadow: ${props => props.theme.shadows.small};

  &:hover {
    background-color: ${props => props.hasInventory ? props.theme.colors.successDark : props.theme.colors.primaryDark};
    transform: scale(1.1);
  }

  svg {
    width: 16px;
    height: 16px;
  }
`;

const Tooltip = styled.div<{ hasInventory: boolean }>`
  position: absolute;
  top: -35px;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 4px 8px;
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  white-space: nowrap;
  pointer-events: none;
  z-index: 100;

  &::after {
    content: "";
    position: absolute;
    bottom: -4px;
    left: 50%;
    transform: translateX(-50%);
    border-width: 4px;
    border-style: solid;
    border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
  }
`;

const CardContent = styled.div`
  padding: ${props => props.theme.spacing.md};
`;

const BeadName = styled.h3`
  margin: 0 0 ${props => props.theme.spacing.xs} 0;
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 600;
  color: ${props => props.theme.colors.text};
  line-height: 1.4;
`;

const ProductCode = styled.p`
  margin: 0 0 ${props => props.theme.spacing.xs} 0;
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.lightText};
  font-family: monospace;
`;

const BrandName = styled.p`
  margin: 0 0 ${props => props.theme.spacing.xs} 0;
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 600;
  color: ${props => props.theme.colors.primary};
`;

const TypeSizeInfo = styled.p`
  margin: 0 0 ${props => props.theme.spacing.sm} 0;
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.lightText};
`;

const TagsContainer = styled.div`
  margin-bottom: ${props => props.theme.spacing.xs};
`;

const TagsLabel = styled.span`
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.lightText};
  font-weight: 500;
  display: inline-block;
  margin-right: ${props => props.theme.spacing.xs};
`;

const Tags = styled.div`
  display: inline;
`;

const ColorTag = styled.span`
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.text};
`;

const FinishTag = styled.span`
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.text};
`;

const GlassTag = styled.span`
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.text};
`;

const CardActions = styled.div`
  display: flex;
  justify-content: flex-end;
  margin-top: ${props => props.theme.spacing.md};
  padding-top: ${props => props.theme.spacing.sm};
  border-top: 1px solid ${props => props.theme.colors.border};
`;

const EditButton = styled.button`
  background-color: transparent;
  color: ${props => props.theme.colors.primary};
  border: 1px solid ${props => props.theme.colors.primary};
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  
  &:hover {
    background-color: ${props => props.theme.colors.primary};
    color: white;
  }
`;

// Component Interface
interface BeadCardProps {
  bead: Bead;
  onEdit: (id: number) => void;
  onView: (id: number) => void;
}

const BeadCard: React.FC<BeadCardProps> = memo(({ bead, onEdit, onView }) => {
  const [showAddToInventoryModal, setShowAddToInventoryModal] = useState(false);
  const [showTooltip, setShowTooltip] = useState(false);

  const handleEditClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit(bead.id);
  };

  const handleInventoryClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowAddToInventoryModal(true);
  };

  const handleCardClick = () => {
    onView(bead.id);
  };

  const hasInventory = !!bead.user_inventory;
  const inventoryTooltip = hasInventory 
    ? `In inventory: ${bead.user_inventory!.quantity} ${bead.user_inventory!.quantity_unit}` 
    : 'Add to inventory';

  return (
    <>
      <CardContainer onClick={handleCardClick}>
        <ImageContainer>
          {bead.image && bead.image.trim() ? (
            <BeadImage src={`/bead-images/${bead.image}`} alt={bead.name} />
          ) : (
            <PlaceholderImage />
          )}
          
          {/* Inventory button overlay */}
          <InventoryButtonOverlay>
            <InventoryButton 
              onClick={handleInventoryClick}
              onMouseEnter={() => setShowTooltip(true)}
              onMouseLeave={() => setShowTooltip(false)}
              hasInventory={hasInventory}
              title={inventoryTooltip}
            >
              {hasInventory ? (
                // Check icon for items in inventory
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M20 6L9 17L4 12"
                    stroke="currentColor"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              ) : (
                // Plus icon for items not in inventory
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M12 5V19M5 12H19"
                    stroke="currentColor"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              )}
              
              {/* Tooltip */}
              {showTooltip && (
                <Tooltip hasInventory={hasInventory}>
                  {inventoryTooltip}
                </Tooltip>
              )}
            </InventoryButton>
          </InventoryButtonOverlay>
        </ImageContainer>

        <CardContent>
          <BeadName>{bead.name}</BeadName>

          {bead.brand_product_code && (
            <ProductCode>{bead.brand_product_code}</ProductCode>
          )}

          <BrandName>{bead.brand.name}</BrandName>

          <TypeSizeInfo>
            {bead.shape} • {bead.size}
          </TypeSizeInfo>

          {bead.color_group && (
            <TagsContainer>
              <TagsLabel>Color:</TagsLabel>
              <Tags>
                <ColorTag>{bead.color_group}</ColorTag>
              </Tags>
            </TagsContainer>
          )}

          {bead.finish && (
            <TagsContainer>
              <TagsLabel>Finish:</TagsLabel>
              <Tags>
                <FinishTag>{bead.finish}</FinishTag>
              </Tags>
            </TagsContainer>
          )}

          {bead.glass_group && (
            <TagsContainer>
              <TagsLabel>Glass:</TagsLabel>
              <Tags>
                <GlassTag>{bead.glass_group}</GlassTag>
              </Tags>
            </TagsContainer>
          )}

          <CardActions>
            <EditButton onClick={handleEditClick}>
              Edit
            </EditButton>
          </CardActions>
        </CardContent>
      </CardContainer>

      {/* Inventory Modal */}
      {showAddToInventoryModal && (
        <AddToInventoryModal
          bead={bead}
          onClose={() => setShowAddToInventoryModal(false)}
        />
      )}
    </>
  );
});

BeadCard.displayName = 'BeadCard';

export default BeadCard; 