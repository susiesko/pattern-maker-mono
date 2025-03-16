import styled, { keyframes } from 'styled-components';
import { Link } from 'react-router-dom';

// Animations
const fadeIn = keyframes`
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
`;

const pulse = keyframes`
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
`;

// Styled components
const WelcomeContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 100px);
  padding: ${props => props.theme.spacing.xl};
  text-align: center;
  animation: ${fadeIn} 0.8s ease-out;
`;

const HeroSection = styled.div`
  margin-bottom: ${props => props.theme.spacing.xxl};
  max-width: 900px;
`;

const Title = styled.h1`
  font-size: ${props => props.theme.fontSizes.xxlarge};
  color: ${props => props.theme.colors.primary};
  margin-bottom: ${props => props.theme.spacing.lg};
  position: relative;
  display: inline-block;

  &::after {
    content: '';
    position: absolute;
    bottom: -10px;
    left: 50%;
    transform: translateX(-50%);
    width: 100px;
    height: 4px;
    background-color: ${props => props.theme.colors.primary};
    border-radius: 2px;
  }
`;

const Subtitle = styled.h2`
  font-size: ${props => props.theme.fontSizes.xlarge};
  color: ${props => props.theme.colors.text};
  margin-bottom: ${props => props.theme.spacing.xl};
`;

const Description = styled.p`
  font-size: ${props => props.theme.fontSizes.large};
  color: ${props => props.theme.colors.lightText};
  max-width: 800px;
  line-height: 1.6;
  margin: 0 auto ${props => props.theme.spacing.xl} auto;
`;

const FeatureList = styled.ul`
  list-style-type: none;
  padding: 0;
  margin: ${props => props.theme.spacing.xl} 0;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: ${props => props.theme.spacing.xl};
  width: 100%;
  max-width: 1200px;
`;

const FeatureItem = styled.li`
  background-color: ${props => props.theme.colors.white};
  padding: ${props => props.theme.spacing.xl};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.medium};
  width: 300px;
  text-align: center;
  transition: all ${props => props.theme.transitions.default};
  border: 1px solid ${props => props.theme.colors.border};

  &:hover {
    transform: translateY(-8px);
    box-shadow: ${props => props.theme.shadows.large};
    border-color: ${props => props.theme.colors.primary};
  }
`;

const FeatureIcon = styled.div`
  font-size: 2.5rem;
  color: ${props => props.theme.colors.primary};
  margin-bottom: ${props => props.theme.spacing.md};
`;

const FeatureTitle = styled.h3`
  color: ${props => props.theme.colors.text};
  margin-bottom: ${props => props.theme.spacing.md};
  font-size: ${props => props.theme.fontSizes.large};
`;

const FeatureDescription = styled.p`
  color: ${props => props.theme.colors.lightText};
  line-height: 1.5;
  margin-bottom: ${props => props.theme.spacing.lg};
`;

const GetStartedButton = styled(Link)`
  display: inline-block;
  background-color: ${props => props.theme.colors.primary};
  color: white;
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.xl};
  border-radius: ${props => props.theme.borderRadius.medium};
  font-weight: bold;
  font-size: ${props => props.theme.fontSizes.medium};
  margin-top: ${props => props.theme.spacing.xl};
  transition: all ${props => props.theme.transitions.default};
  animation: ${pulse} 2s infinite ease-in-out;
  box-shadow: ${props => props.theme.shadows.medium};

  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
    transform: scale(1.05);
    box-shadow: ${props => props.theme.shadows.large};
  }
`;

// Icons (using emoji as placeholders - in a real app, you'd use SVG icons or an icon library)
const BeadIcon = () => <span role="img" aria-label="Bead">💎</span>;
const DesignIcon = () => <span role="img" aria-label="Design">🎨</span>;
const ProjectIcon = () => <span role="img" aria-label="Project">📁</span>;

const WelcomePage = () => {
  return (
    <WelcomeContainer>
      <HeroSection>
        <Title>Welcome to Pattern Maker</Title>
        <Subtitle>Create beautiful bead patterns with ease</Subtitle>
        <Description>
          Pattern Maker is a powerful tool designed to help you create, manage, and share your bead patterns.
          Browse our extensive bead catalog, design intricate patterns, and bring your creative vision to life.
        </Description>
        <GetStartedButton to="/beads">Explore Bead Catalog</GetStartedButton>
      </HeroSection>

      <FeatureList>
        <FeatureItem>
          <FeatureIcon><BeadIcon /></FeatureIcon>
          <FeatureTitle>Bead Catalog</FeatureTitle>
          <FeatureDescription>
            Browse our extensive collection of beads from various brands, colors, and sizes. Find the perfect beads for your next project.
          </FeatureDescription>
        </FeatureItem>
        <FeatureItem>
          <FeatureIcon><DesignIcon /></FeatureIcon>
          <FeatureTitle>Pattern Designer</FeatureTitle>
          <FeatureDescription>
            Create intricate patterns with our intuitive design tools. Visualize your designs before you start beading.
          </FeatureDescription>
        </FeatureItem>
        <FeatureItem>
          <FeatureIcon><ProjectIcon /></FeatureIcon>
          <FeatureTitle>Project Management</FeatureTitle>
          <FeatureDescription>
            Save, organize, and track your beading projects in one place. Never lose track of your creative ideas again.
          </FeatureDescription>
        </FeatureItem>
      </FeatureList>
    </WelcomeContainer>
  );
};

export default WelcomePage;