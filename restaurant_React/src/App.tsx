import { BrowserRouter } from 'react-router-dom';
import { AppShell } from '@presentation/components/layout/AppShell';
import { ErrorBoundary } from '@presentation/components/layout/ErrorBoundary';
import { AppRoutes } from '@presentation/routes/AppRoutes';

export const App = () => (
  <BrowserRouter>
    <AppShell>
      <ErrorBoundary>
        <AppRoutes />
      </ErrorBoundary>
    </AppShell>
  </BrowserRouter>
);
