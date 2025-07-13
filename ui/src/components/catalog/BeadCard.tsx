import React, { memo } from 'react';
import styled from 'styled-components';
import { Bead } from '../../types/beads';

interface BeadCardProps {
  bead: Bead;
  onEdit: (id: number) => void;
  onView: (id: number) => void;
}

const BeadCard: React.FC<BeadCardProps> = memo(({ bead, onEdit, onView }) => {
  const handleEditClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit(bead.id);
  };

  const handleCardClick = () => {
    onView(bead.id);
  };

  return (
    <CardContainer onClick={handleCardClick}>
      <ImageContainer>
        {bead.image && bead.image.trim() ? (
          <BeadImage src={`/bead-images/${bead.image}`} alt={bead.name} />
        ) : (
          <PlaceholderImage />
        )}
      </ImageContainer>

      <CardContent>
        <BeadName>{bead.name}</BeadName>

        {bead.brand_product_code && (
          <ProductCode>{bead.brand_product_code}</ProductCode>
        )}

        <BrandName>{bead.brand.name}</BrandName>

        <TypeSizeInfo>
          {bead.type.name} • {bead.size.size}
        </TypeSizeInfo>

        {bead.colors.length > 0 && (
          <TagsContainer>
            <TagsLabel>Colors:</TagsLabel>
            <Tags>
              {bead.colors.map((color, index) => (
                <ColorTag key={color.id}>
                  {color.name}
                  {index < bead.colors.length - 1 && ', '}
                </ColorTag>
              ))}
            </Tags>
          </TagsContainer>
        )}

        {bead.finishes.length > 0 && (
          <TagsContainer>
            <TagsLabel>Finishes:</TagsLabel>
            <Tags>
              {bead.finishes.map((finish, index) => (
                <FinishTag key={finish.id}>
                  {finish.name}
                  {index < bead.finishes.length - 1 && ', '}
                </FinishTag>
              ))}
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
  );
});

BeadCard.displayName = 'BeadCard';

export default BeadCard;

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