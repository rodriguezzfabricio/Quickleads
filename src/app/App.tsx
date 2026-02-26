import { RouterProvider } from 'react-router';
import { App as KonstaApp } from 'konsta/react';
import { router } from './routes';
import { LeadsProvider } from './state/LeadsContext';

export default function App() {
  return (
    <KonstaApp theme="ios" dark safeAreas>
      {/* App-wide leads state keeps lead actions in sync across screens. */}
      <LeadsProvider>
        <RouterProvider router={router} />
      </LeadsProvider>
    </KonstaApp>
  );
}
