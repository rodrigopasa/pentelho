import { Card, CardContent } from "@/components/ui/card";
import { AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Link } from "wouter";

export default function NotFound() {
  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-dark-bg">
      <Card className="w-full max-w-md mx-4 bg-dark-surface border-dark-border">
        <CardContent className="pt-6">
          <div className="flex mb-4 gap-2">
            <AlertCircle className="h-8 w-8 text-destructive" />
            <h1 className="text-2xl font-bold text-dark-text">404 - Página não encontrada</h1>
          </div>

          <p className="mt-4 text-sm text-gray-400 mb-6">
            A página que você está procurando não existe ou foi movida.
          </p>
          
          <Link href="/">
            <Button className="w-full bg-primary hover:bg-primary-dark text-white">
              Voltar para a página inicial
            </Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}
