import { Outlet } from 'react-router-dom';
import styled from 'styled-components';
import Navigation from './Navigation';

const LayoutContainer = styled.div`
  display: flex;
  min-height: 100vh;
  background-color: ${props => props.theme.colors.secondary};
`;

const Content = styled.main`
  flex: 1;
  margin-left: 250px; /* Same as navigation width */
  padding: ${props => props.theme.spacing.xl};
  position: relative;
  overflow-x: hidden;
`;

const ContentWrapper = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.small};
  min-height: calc(100vh - ${props => props.theme.spacing.xl} * 2);
  overflow: hidden;
`;

const Layout = () => {
  return (
    <LayoutContainer>
      <Navigation />
      <Content>
        <ContentWrapper>
          <Outlet />
        </ContentWrapper>
      </Content>
    </LayoutContainer>
  );
};

export default Layout;