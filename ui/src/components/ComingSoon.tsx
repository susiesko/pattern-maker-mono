import styled, { keyframes } from 'styled-components';

// Animation for the coming soon text
const pulse = keyframes`
  0% {
    opacity: 0.6;
  }
  50% {
    opacity: 1;
  }
  100% {
    opacity: 0.6;
  }
`;

const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 70vh;
  padding: ${props => props.theme.spacing.xl};
  text-align: center;
`;

const Title = styled.h1`
  font-size: ${props => props.theme.fontSizes.xxlarge};
  color: ${props => props.theme.colors.primary};
  margin-bottom: ${props => props.theme.spacing.lg};
`;

const ComingSoonText = styled.div`
  font-size: ${props => props.theme.fontSizes.xlarge};
  color: ${props => props.theme.colors.lightText};
  margin: ${props => props.theme.spacing.xl} 0;
  animation: ${pulse} 2s infinite ease-in-out;
  padding: ${props => props.theme.spacing.lg};
  border: 2px dashed ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.medium};
  display: inline-block;
`;

const Description = styled.p`
  font-size: ${props => props.theme.fontSizes.large};
  color: ${props => props.theme.colors.text};
  max-width: 600px;
  line-height: 1.6;
`;

interface ComingSoonProps {
  title: string;
}

const ComingSoon = ({ title }: ComingSoonProps) => {
  return (
    <Container>
      <Title>{title}</Title>
      <ComingSoonText>Coming Soon</ComingSoonText>
      <Description>
        We're working hard to bring you this feature. 
        Please check back soon for updates!
      </Description>
    </Container>
  );
};

export default ComingSoon;