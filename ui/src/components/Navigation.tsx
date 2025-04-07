import { Link, useLocation, useNavigate } from 'react-router-dom';
import styled from 'styled-components';
import { useAuth } from '../context/AuthContext';

const NavContainer = styled.nav`
  width: 250px;
  background-color: ${props => props.theme.colors.white};
  height: 100vh;
  padding: ${props => props.theme.spacing.lg} 0;
  box-shadow: ${props => props.theme.shadows.medium};
  position: fixed;
  left: 0;
  top: 0;
  border-right: 1px solid ${props => props.theme.colors.border};
  display: flex;
  flex-direction: column;
  z-index: 100;
`;

const LogoContainer = styled.div`
  padding: 0 ${props => props.theme.spacing.lg};
  margin-bottom: ${props => props.theme.spacing.xl};
`;

const Logo = styled.div`
  font-size: ${props => props.theme.fontSizes.xlarge};
  font-weight: bold;
  color: ${props => props.theme.colors.primary};
  padding: ${props => props.theme.spacing.md} 0;
  border-bottom: 1px solid ${props => props.theme.colors.border};
  text-align: center;
`;

const NavList = styled.ul`
  list-style-type: none;
  padding: 0;
  margin: 0;
  flex: 1;
`;

const NavItem = styled.li`
  margin-bottom: ${props => props.theme.spacing.sm};
`;

const NavLink = styled(Link)<{ active: boolean }>`
  display: flex;
  align-items: center;
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  color: ${props => props.active ? props.theme.colors.primary : props.theme.colors.text};
  text-decoration: none;
  transition: all ${props => props.theme.transitions.default};
  font-weight: ${props => props.active ? 'bold' : 'normal'};
  border-left: 4px solid ${props => props.active ? props.theme.colors.primary : 'transparent'};
  background-color: ${props => props.active ? props.theme.colors.secondary : 'transparent'};

  &:hover {
    background-color: ${props => props.theme.colors.secondary};
    color: ${props => props.theme.colors.primary};
    border-left-color: ${props => props.theme.colors.primaryDark};
  }
`;

const NavButton = styled.button`
  display: flex;
  align-items: center;
  width: 100%;
  text-align: left;
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  color: ${props => props.theme.colors.text};
  background: none;
  border: none;
  font-size: ${props => props.theme.fontSizes.medium};
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  border-left: 4px solid transparent;

  &:hover {
    background-color: ${props => props.theme.colors.secondary};
    color: ${props => props.theme.colors.primary};
    border-left-color: ${props => props.theme.colors.primaryDark};
  }
`;

const IconWrapper = styled.span`
  margin-right: ${props => props.theme.spacing.md};
  font-size: 1.2rem;
`;

const Footer = styled.div`
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.small};
  color: ${props => props.theme.colors.lightText};
  text-align: center;
  border-top: 1px solid ${props => props.theme.colors.border};
`;

const UserSection = styled.div`
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  margin-bottom: ${props => props.theme.spacing.md};
  border-top: 1px solid ${props => props.theme.colors.border};
`;

const UserInfo = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing.sm};
  font-size: ${props => props.theme.fontSizes.medium};
`;

const UserAvatar = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: ${props => props.theme.colors.primary};
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: ${props => props.theme.spacing.sm};
  font-weight: bold;
`;

// Simple icon components using emoji (in a real app, you'd use SVG icons or an icon library)
const HomeIcon = () => <span role="img" aria-label="Home">🏠</span>;
const CatalogIcon = () => <span role="img" aria-label="Catalog">💎</span>;
const DesignerIcon = () => <span role="img" aria-label="Designer">🎨</span>;
const ProjectsIcon = () => <span role="img" aria-label="Projects">📁</span>;
const LoginIcon = () => <span role="img" aria-label="Login">🔑</span>;
const RegisterIcon = () => <span role="img" aria-label="Register">📝</span>;
const LogoutIcon = () => <span role="img" aria-label="Logout">🚪</span>;

const Navigation = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { isAuthenticated, user, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  // Get the first letter of the user's name for the avatar
  const getInitial = () => {
    return user?.name ? user.name.charAt(0).toUpperCase() : '?';
  };

  return (
    <NavContainer>
      <LogoContainer>
        <Logo>Pattern Maker</Logo>
      </LogoContainer>

      <NavList>
        <NavItem>
          <NavLink to="/" active={location.pathname === '/'}>
            <IconWrapper><HomeIcon /></IconWrapper>
            Home
          </NavLink>
        </NavItem>
        <NavItem>
          <NavLink to="/beads" active={location.pathname === '/beads'}>
            <IconWrapper><CatalogIcon /></IconWrapper>
            Bead Catalog
          </NavLink>
        </NavItem>
        <NavItem>
          <NavLink to="/designer" active={location.pathname === '/designer'}>
            <IconWrapper><DesignerIcon /></IconWrapper>
            Pattern Designer
          </NavLink>
        </NavItem>
        <NavItem>
          <NavLink to="/projects" active={location.pathname === '/projects'}>
            <IconWrapper><ProjectsIcon /></IconWrapper>
            My Projects
          </NavLink>
        </NavItem>
      </NavList>

      {isAuthenticated ? (
        <UserSection>
          <UserInfo>
            <UserAvatar>{getInitial()}</UserAvatar>
            <div>{user?.name}</div>
          </UserInfo>
          <NavButton onClick={handleLogout}>
            <IconWrapper><LogoutIcon /></IconWrapper>
            Logout
          </NavButton>
        </UserSection>
      ) : (
        <UserSection>
          <NavItem>
            <NavLink to="/login" active={location.pathname === '/login'}>
              <IconWrapper><LoginIcon /></IconWrapper>
              Login
            </NavLink>
          </NavItem>
          <NavItem>
            <NavLink to="/register" active={location.pathname === '/register'}>
              <IconWrapper><RegisterIcon /></IconWrapper>
              Register
            </NavLink>
          </NavItem>
        </UserSection>
      )}

      <Footer>
        Pattern Maker v1.0.0
      </Footer>
    </NavContainer>
  );
};

export default Navigation;