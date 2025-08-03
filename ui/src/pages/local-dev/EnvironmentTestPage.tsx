import React from 'react';
import styled from 'styled-components';
import { getEnvironmentInfo } from '../../utils/envUtils';

const Container = styled.div`
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
`;

const InfoCard = styled.div`
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
  margin: 1rem 0;
`;

const EnvironmentTestPage: React.FC = () => {
  const envInfo = getEnvironmentInfo();

  return (
    <Container>
      <h1>Environment Test Page</h1>
      <p>This page is only available in development mode.</p>
      
      <InfoCard>
        <h3>Environment Information:</h3>
        <pre>{JSON.stringify(envInfo, null, 2)}</pre>
      </InfoCard>

      <InfoCard>
        <h3>How it works:</h3>
        <ul>
          <li>This page is in <code>src/pages/local-dev/</code></li>
          <li>It's only imported when <code>import.meta.env.DEV</code> is true</li>
          <li>In production builds, this code won't be included</li>
        </ul>
      </InfoCard>
    </Container>
  );
};

export default EnvironmentTestPage; 