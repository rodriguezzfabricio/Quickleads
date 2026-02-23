import { RouterProvider } from 'react-router';
import { App as KonstaApp } from 'konsta/react';
import { router } from './routes';

export default function App() {
  return (
    <KonstaApp theme="ios" dark safeAreas>
      <RouterProvider router={router} />
    </KonstaApp>
  );
}
